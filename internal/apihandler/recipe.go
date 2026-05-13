package apihandler

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"sort"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/storage"
	"searlo-cafe/internal/units"

	"github.com/google/uuid"
)

type RecipeAPIHandler struct {
	store *storage.ImageStore
}

func NewRecipeAPIHandler(store *storage.ImageStore) *RecipeAPIHandler {
	return &RecipeAPIHandler{store: store}
}

func (h *RecipeAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/recipes", wrap(h.list, "menu_items", "read"))
	mux.Handle("POST /api/v1/recipes", wrap(h.create, "menu_items", "create"))
	mux.Handle("GET /api/v1/recipes/categories", wrap(h.listCategories, "menu_items", "read"))
	mux.Handle("POST /api/v1/recipes/categories", wrap(h.createCategory, "menu_items", "create"))
	mux.Handle("GET /api/v1/recipes/{id}", wrap(h.show, "menu_items", "read"))
	mux.Handle("PUT /api/v1/recipes/{id}", wrap(h.update, "menu_items", "update"))
	mux.Handle("DELETE /api/v1/recipes/{id}", wrap(h.delete, "menu_items", "delete"))
	mux.Handle("POST /api/v1/recipes/{id}/ingredients", wrap(h.addIngredient, "menu_items", "update"))
	mux.Handle("PUT /api/v1/recipes/{id}/ingredients/{riId}", wrap(h.updateIngredient, "menu_items", "update"))
	mux.Handle("DELETE /api/v1/recipes/{id}/ingredients/{riId}", wrap(h.removeIngredient, "menu_items", "update"))
	mux.Handle("POST /api/v1/recipes/{id}/utility-costs", wrap(h.setUtilityCost, "menu_items", "update"))
	mux.Handle("DELETE /api/v1/recipes/{id}/utility-costs/{ucId}", wrap(h.removeUtilityCost, "menu_items", "update"))
}

func (h *RecipeAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	q := r.URL.Query()
	search := q.Get("search")
	category := q.Get("category")
	status := q.Get("status")
	sortBy := q.Get("sort")

	var ingredientIDs []uuid.UUID
	for _, idStr := range strings.Split(q.Get("ingredients"), ",") {
		idStr = strings.TrimSpace(idStr)
		if id, err := uuid.Parse(idStr); err == nil {
			ingredientIDs = append(ingredientIDs, id)
		}
	}

	items, err := repo.ListRecipes(r.Context(), search, category, status, sortBy, ingredientIDs)
	if err != nil {
		slog.Error("api: list recipes", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list recipes")
		return
	}

	for i := range items {
		recipeIngs, _ := repo.GetRecipeIngredients(r.Context(), items[i].ID)
		utilityCosts, _ := repo.GetUtilityCosts(r.Context(), items[i].ID)
		items[i].Ingredients = recipeIngs
		items[i].UtilityCosts = utilityCosts
		items[i].TotalCost = apiCalculateTotalCost(recipeIngs, utilityCosts)
		if items[i].Yield < 1 {
			items[i].Yield = 1
		}
		items[i].CostPerPortion = items[i].TotalCost / float64(items[i].Yield)
		if items[i].SellingPrice > 0 {
			items[i].CostMargin = ((items[i].SellingPrice - items[i].CostPerPortion) / items[i].SellingPrice) * 100
			items[i].NetProfit = items[i].SellingPrice - items[i].CostPerPortion
		}
	}

	if sortBy == "margin_desc" || sortBy == "margin_asc" || sortBy == "cost_asc" || sortBy == "cost_desc" {
		sort.Slice(items, func(i, j int) bool {
			switch sortBy {
			case "margin_desc":
				return items[i].CostMargin > items[j].CostMargin
			case "margin_asc":
				return items[i].CostMargin < items[j].CostMargin
			case "cost_asc":
				return items[i].TotalCost < items[j].TotalCost
			case "cost_desc":
				return items[i].TotalCost > items[j].TotalCost
			}
			return false
		})
	}

	writeJSON(w, http.StatusOK, items)
}

func (h *RecipeAPIHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	item, err := repo.GetRecipeByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "recipe not found")
		return
	}

	recipeIngs, _ := repo.GetRecipeIngredients(r.Context(), id)
	utilityCosts, _ := repo.GetUtilityCosts(r.Context(), id)
	unitList, _ := ingredientRepo.ListUnits(r.Context())

	for i := range recipeIngs {
		ri := &recipeIngs[i]
		if ri.DisplayUnitID == nil && ri.Ingredient != nil && ri.Ingredient.Unit != nil {
			best, bestQty := units.BestDisplay(ri.Quantity, ri.Ingredient.Unit, unitList)
			ri.DisplayUnit = best
			ri.DisplayQuantity = bestQty
		}
	}

	item.Ingredients = recipeIngs
	item.UtilityCosts = utilityCosts
	item.TotalCost = apiCalculateTotalCost(recipeIngs, utilityCosts)
	if item.Yield < 1 {
		item.Yield = 1
	}
	item.CostPerPortion = item.TotalCost / float64(item.Yield)
	if item.SellingPrice > 0 {
		item.CostMargin = ((item.SellingPrice - item.CostPerPortion) / item.SellingPrice) * 100
		item.NetProfit = item.SellingPrice - item.CostPerPortion
	}

	alertCounts, _ := ingredientRepo.GetUnreadAlertsByIngredient(r.Context())

	writeJSON(w, http.StatusOK, map[string]any{
		"recipe":       item,
		"alert_counts": alertCounts,
	})
}

func (h *RecipeAPIHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "request too large")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	var catID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			catID = &parsed
		}
	}

	status := r.FormValue("status")
	if status == "" {
		status = "draft"
	}

	var imagePath string
	file, header, err := r.FormFile("image")
	if err == nil {
		defer file.Close()
		if h.store != nil {
			orgDB := middleware.GetOrgDB(r.Context())
			key, uploadErr := h.store.Upload(r.Context(), orgDB, "recipes", file, header.Filename)
			if uploadErr != nil {
				slog.Error("recipe image upload failed", "error", uploadErr)
			} else {
				imagePath = key
			}
		}
	}

	allergens := apiSplitAndTrim(r.FormValue("allergens"))

	params := repository.CreateRecipeParams{
		CategoryID:       catID,
		Name:             strings.TrimSpace(r.FormValue("name")),
		Description:      strings.TrimSpace(r.FormValue("description")),
		ImagePath:        imagePath,
		SellingPrice:     apiParseFloat(r.FormValue("selling_price")),
		Status:           status,
		PreparationNotes: strings.TrimSpace(r.FormValue("preparation_notes")),
		Allergens:        allergens,
		Yield:            apiParseYield(r.FormValue("yield")),
		YieldUnit:        strings.TrimSpace(r.FormValue("yield_unit")),
	}

	if params.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	item, err := repo.CreateRecipe(r.Context(), params)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "idx_menu_items_unique_name") {
			writeError(w, http.StatusConflict, "a recipe with this name already exists")
		} else {
			slog.Error("api: create recipe", "error", err)
			writeError(w, http.StatusInternalServerError, "failed to create recipe")
		}
		return
	}

	// Audit log: create recipe
	if newJSON, err := json.Marshal(item); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "create", "recipe", item.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, item)
}

func (h *RecipeAPIHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "request too large")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	var catID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			catID = &parsed
		}
	}

	status := r.FormValue("status")
	if status == "" {
		status = "active"
	}

	var imagePath string
	file, header, err := r.FormFile("image")
	if err == nil {
		defer file.Close()
		if h.store != nil {
			orgDB := middleware.GetOrgDB(r.Context())
			key, uploadErr := h.store.Upload(r.Context(), orgDB, "recipes", file, header.Filename)
			if uploadErr != nil {
				slog.Error("recipe image upload failed", "error", uploadErr)
			} else {
				imagePath = key
			}
		}
	}

	if imagePath == "" {
		imagePath = r.FormValue("existing_image_path")
	}

	params := repository.CreateRecipeParams{
		CategoryID:       catID,
		Name:             strings.TrimSpace(r.FormValue("name")),
		Description:      strings.TrimSpace(r.FormValue("description")),
		ImagePath:        imagePath,
		SellingPrice:     apiParseFloat(r.FormValue("selling_price")),
		Status:           status,
		PreparationNotes: strings.TrimSpace(r.FormValue("preparation_notes")),
		Allergens:        apiSplitAndTrim(r.FormValue("allergens")),
		Yield:            apiParseYield(r.FormValue("yield")),
		YieldUnit:        strings.TrimSpace(r.FormValue("yield_unit")),
	}

	oldItem, _ := repo.GetRecipeByID(r.Context(), id)

	if err := repo.UpdateRecipe(r.Context(), id, params); err != nil {
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "idx_menu_items_unique_name") {
			writeError(w, http.StatusConflict, "a recipe with this name already exists")
		} else {
			slog.Error("api: update recipe", "error", err)
			writeError(w, http.StatusInternalServerError, "failed to update recipe")
		}
		return
	}

	item, _ := repo.GetRecipeByID(r.Context(), id)

	// Audit log: update recipe
	oldJSON, _ := json.Marshal(oldItem)
	newJSON, _ := json.Marshal(item)
	auditRepo := repository.NewAuditRepo(pool)
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "update", "recipe", id, oldJSON, newJSON, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, item)
}

func (h *RecipeAPIHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	oldItem, _ := repo.GetRecipeByID(r.Context(), id)

	if err := repo.DeleteRecipe(r.Context(), id); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to delete recipe")
		return
	}

	// Audit log: delete recipe
	if oldJSON, err := json.Marshal(oldItem); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "delete", "recipe", id, oldJSON, nil, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "deleted"})
}

type addIngredientRequest struct {
	IngredientID   string  `json:"ingredient_id"`
	Quantity       float64 `json:"quantity"`
	IngredientType string  `json:"ingredient_type"`
	QuantityUnitID string  `json:"quantity_unit_id"`
}

func (h *RecipeAPIHandler) addIngredient(w http.ResponseWriter, r *http.Request) {
	var req addIngredientRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	menuItemID, _ := uuid.Parse(r.PathValue("id"))
	ingredientID, err := uuid.Parse(req.IngredientID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid ingredient_id")
		return
	}

	if req.IngredientType == "" {
		req.IngredientType = "primary"
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	qty := req.Quantity
	var displayUnitID *uuid.UUID
	if req.QuantityUnitID != "" {
		if quID, err := uuid.Parse(req.QuantityUnitID); err == nil {
			displayUnitID = &quID
			ing, err := ingredientRepo.GetByID(r.Context(), ingredientID)
			if err != nil || ing.Unit == nil {
				writeError(w, http.StatusBadRequest, "ingredient not found")
				return
			}
			if quID != ing.UnitID {
				qUnit, err := ingredientRepo.GetUnitByID(r.Context(), quID)
				if err != nil {
					writeError(w, http.StatusBadRequest, "invalid quantity_unit_id")
					return
				}
				converted, err := units.ConvertQuantity(qty, qUnit, ing.Unit)
				if err != nil {
					writeError(w, http.StatusBadRequest, err.Error())
					return
				}
				qty = converted
			}
		}
	}

	if err := repo.AddRecipeIngredient(r.Context(), menuItemID, ingredientID, qty, req.IngredientType, "", displayUnitID); err != nil {
		slog.Error("api: add recipe ingredient", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to add ingredient")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "ingredient added"})
}

type updateIngredientRequest struct {
	Quantity       float64 `json:"quantity"`
	IngredientType string  `json:"ingredient_type"`
	QuantityUnitID string  `json:"quantity_unit_id"`
}

func (h *RecipeAPIHandler) updateIngredient(w http.ResponseWriter, r *http.Request) {
	var req updateIngredientRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	riID, err := uuid.Parse(r.PathValue("riId"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	ri, err := repo.GetRecipeIngredientByID(r.Context(), riID)
	if err != nil {
		writeError(w, http.StatusNotFound, "recipe ingredient not found")
		return
	}

	ingType := req.IngredientType
	if ingType == "" {
		ingType = ri.IngredientType
	}

	qty := req.Quantity
	var displayUnitID *uuid.UUID
	if req.QuantityUnitID != "" {
		if quID, err := uuid.Parse(req.QuantityUnitID); err == nil {
			displayUnitID = &quID
			if quID != ri.Ingredient.UnitID {
				qUnit, err := ingredientRepo.GetUnitByID(r.Context(), quID)
				if err != nil {
					writeError(w, http.StatusBadRequest, "invalid quantity_unit_id")
					return
				}
				converted, err := units.ConvertQuantity(qty, qUnit, ri.Ingredient.Unit)
				if err != nil {
					writeError(w, http.StatusBadRequest, err.Error())
					return
				}
				qty = converted
			}
		}
	}

	if err := repo.UpdateRecipeIngredient(r.Context(), riID, qty, ingType, displayUnitID); err != nil {
		slog.Error("api: update recipe ingredient", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to update ingredient")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "ingredient updated"})
}

func (h *RecipeAPIHandler) removeIngredient(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	riID, err := uuid.Parse(r.PathValue("riId"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	if err := repo.RemoveRecipeIngredient(r.Context(), riID); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to remove ingredient")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "ingredient removed"})
}

type setUtilityCostRequest struct {
	Name string  `json:"name"`
	Cost float64 `json:"cost"`
}

// setUtilityCost writes a per-recipe ad-hoc utility cost (extra). Shared
// tenant-level costs are managed separately and linked via different endpoints.
func (h *RecipeAPIHandler) setUtilityCost(w http.ResponseWriter, r *http.Request) {
	var req setUtilityCostRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	menuItemID, _ := uuid.Parse(r.PathValue("id"))

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	if _, err := repo.AddUtilityExtra(r.Context(), menuItemID, req.Name, req.Cost); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to set utility cost")
		return
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, "Extra "+req.Name+" added")

	writeJSON(w, http.StatusOK, map[string]string{"message": "utility cost set"})
}

func (h *RecipeAPIHandler) removeUtilityCost(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	ucID, err := uuid.Parse(r.PathValue("ucId"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	menuItemID, name, err := repo.RemoveUtilityExtra(r.Context(), ucID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to remove utility cost")
		return
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, "Extra "+name+" removed")

	writeJSON(w, http.StatusOK, map[string]string{"message": "utility cost removed"})
}

func (h *RecipeAPIHandler) listCategories(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	categories, err := repo.ListCategories(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list categories")
		return
	}

	writeJSON(w, http.StatusOK, categories)
}

type createCategoryRequest struct {
	Name      string `json:"name"`
	SortOrder int    `json:"sort_order"`
}

func (h *RecipeAPIHandler) createCategory(w http.ResponseWriter, r *http.Request) {
	var req createCategoryRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	cat, err := repo.CreateCategory(r.Context(), req.Name, req.SortOrder)
	if err != nil {
		slog.Error("api: create category", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create category")
		return
	}

	writeJSON(w, http.StatusCreated, cat)
}

func apiCalculateTotalCost(ingredients []model.RecipeIngredient, utilities []model.RecipeUtilityCost) float64 {
	total := 0.0
	for _, ri := range ingredients {
		total += ri.LineCost
	}
	for _, uc := range utilities {
		total += uc.Cost
	}
	return total
}

func apiSplitAndTrim(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	var result []string
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			result = append(result, p)
		}
	}
	return result
}
