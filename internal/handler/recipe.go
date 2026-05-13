package handler

import (
	"fmt"
	"log/slog"
	"net/http"
	"sort"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/units"
	"searlo-cafe/internal/storage"

	"github.com/google/uuid"
)

type RecipeHandler struct {
	render *Renderer
	store  *storage.ImageStore
}

func NewRecipeHandler(render *Renderer, store *storage.ImageStore) *RecipeHandler {
	return &RecipeHandler{render: render, store: store}
}

func (h *RecipeHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
	wrap := func(handler http.HandlerFunc, perms ...string) http.Handler {
		var chain http.Handler = handler
		if len(perms) == 2 {
			chain = middleware.RequirePermission(perms[0], perms[1])(chain)
		}
		chain = tenantMw(chain)
		chain = orgMw(chain)
		chain = authMw(chain)
		return chain
	}

	mux.Handle("GET /recipes", wrap(h.list, "menu_items", "read"))
	mux.Handle("GET /recipes/preview", wrap(h.preview, "menu_items", "read"))
	mux.Handle("GET /recipes/new", wrap(h.showCreate, "menu_items", "create"))
	mux.Handle("POST /recipes", wrap(h.create, "menu_items", "create"))
	mux.Handle("GET /recipes/{id}", wrap(h.show, "menu_items", "read"))
	mux.Handle("GET /recipes/{id}/edit", wrap(h.showEdit, "menu_items", "update"))
	mux.Handle("PUT /recipes/{id}", wrap(h.update, "menu_items", "update"))
	mux.Handle("DELETE /recipes/{id}", wrap(h.delete, "menu_items", "delete"))
	mux.Handle("POST /recipes/{id}/prep-details", wrap(h.updatePrepDetails, "menu_items", "update"))
	mux.Handle("POST /recipes/{id}/ingredients", wrap(h.addIngredient, "menu_items", "update"))
	mux.Handle("PUT /recipes/{id}/ingredients/{riId}", wrap(h.updateIngredient, "menu_items", "update"))
	mux.Handle("DELETE /recipes/{id}/ingredients/{riId}", wrap(h.removeIngredient, "menu_items", "update"))
	mux.Handle("PUT /recipes/{id}/utility-costs/{ucId}", wrap(h.toggleUtilityCost, "menu_items", "update"))
	mux.Handle("POST /recipes/{id}/utility-extras", wrap(h.addUtilityExtra, "menu_items", "update"))
	mux.Handle("DELETE /recipes/{id}/utility-extras/{eid}", wrap(h.removeUtilityExtra, "menu_items", "update"))
	mux.Handle("POST /recipes/{id}/toggle-status", wrap(h.toggleStatus, "menu_items", "update"))
	mux.Handle("POST /recipes/categories", wrap(h.createCategory, "menu_items", "create"))
}

type recipeGroup struct {
	Category     string
	Items        []model.MenuItem
	TotalCost    float64
	TotalRevenue float64
	TotalProfit  float64
}

func (h *RecipeHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

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
		slog.Error("list recipes", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	for i := range items {
		recipeIngs, _ := repo.GetRecipeIngredients(r.Context(), items[i].ID)
		utilityCosts, _ := repo.GetUtilityCosts(r.Context(), items[i].ID)
		items[i].TotalCost = calculateTotalCost(recipeIngs, utilityCosts)
		if items[i].Yield < 1 {
			items[i].Yield = 1
		}
		items[i].CostPerPortion = items[i].TotalCost / float64(items[i].Yield)
		if items[i].SellingPrice > 0 {
			items[i].CostMargin = ((items[i].SellingPrice - items[i].CostPerPortion) / items[i].SellingPrice) * 100
			items[i].NetProfit = items[i].SellingPrice - items[i].CostPerPortion
		}
	}

	// Sort by margin/cost after calculation if needed.
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

	// Group items by category.
	groupMap := make(map[string]*recipeGroup)
	var groupOrder []string
	for _, item := range items {
		catName := "Uncategorized"
		if item.Category != nil && item.Category.Name != "" {
			catName = item.Category.Name
		}
		g, ok := groupMap[catName]
		if !ok {
			g = &recipeGroup{Category: catName}
			groupMap[catName] = g
			groupOrder = append(groupOrder, catName)
		}
		g.Items = append(g.Items, item)
		g.TotalCost += item.TotalCost
		// TotalRevenue / TotalProfit reflect the full batch potential.
		// For yield=1 items this collapses to the previous SellingPrice / NetProfit.
		g.TotalRevenue += item.SellingPrice * float64(item.Yield)
		g.TotalProfit += item.NetProfit * float64(item.Yield)
	}

	var groups []recipeGroup
	for _, name := range groupOrder {
		groups = append(groups, *groupMap[name])
	}

	categories, _ := repo.ListCategories(r.Context())
	allIngredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")

	h.render.HTML(w, r, "recipes.html", map[string]any{
		"Items":          items,
		"Groups":         groups,
		"Categories":     categories,
		"AllIngredients": allIngredients,
		"Filters": map[string]string{
			"search":      search,
			"category":    category,
			"status":      status,
			"sort":        sortBy,
			"ingredients": q.Get("ingredients"),
		},
		"Title": "Recipes",
	})
}

type menuPreviewGroup struct {
	Name  string
	Items []model.MenuItem
}

func (h *RecipeHandler) preview(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	items, err := repo.ListRecipes(r.Context(), "", "", "active", "", nil)
	if err != nil {
		slog.Error("preview: list recipes", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	categories, _ := repo.ListCategories(r.Context())

	// Group items by category, preserving the sort_order from ListCategories.
	grouped := make(map[uuid.UUID][]model.MenuItem)
	var uncategorized []model.MenuItem
	for _, item := range items {
		if item.CategoryID == nil {
			uncategorized = append(uncategorized, item)
			continue
		}
		grouped[*item.CategoryID] = append(grouped[*item.CategoryID], item)
	}

	var groups []menuPreviewGroup
	for _, c := range categories {
		if rs := grouped[c.ID]; len(rs) > 0 {
			groups = append(groups, menuPreviewGroup{Name: c.Name, Items: rs})
		}
	}
	if len(uncategorized) > 0 {
		groups = append(groups, menuPreviewGroup{Name: "Uncategorized", Items: uncategorized})
	}

	h.render.HTML(w, r, "menu_preview.html", map[string]any{
		"Groups": groups,
		"Title":  "Menu Preview",
	})
}

func (h *RecipeHandler) showCreate(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	categories, _ := repo.ListCategories(r.Context())

	h.render.HTML(w, r, "recipe_form.html", map[string]any{
		"Categories": categories,
		"Title":      "Add Recipe",
	})
}

func (h *RecipeHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Request too large", http.StatusBadRequest)
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

	allergens := splitAndTrim(r.FormValue("allergens"))

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
	} else if err != http.ErrMissingFile {
		slog.Error("form file error", "error", err)
	}

	params := repository.CreateRecipeParams{
		CategoryID:       catID,
		Name:             strings.TrimSpace(r.FormValue("name")),
		Description:      strings.TrimSpace(r.FormValue("description")),
		ImagePath:        imagePath,
		SellingPrice:     parseFloat(r.FormValue("selling_price")),
		Status:           status,
		PreparationNotes: strings.TrimSpace(r.FormValue("preparation_notes")),
		Allergens:        allergens,
		Yield:            parseYield(r.FormValue("yield")),
		YieldUnit:        strings.TrimSpace(r.FormValue("yield_unit")),
	}

	item, err := repo.CreateRecipe(r.Context(), params)
	if err != nil {
		errMsg := "Failed to create recipe"
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "idx_menu_items_unique_name") {
			errMsg = "A recipe with this name already exists"
		} else {
			slog.Error("create recipe", "error", err)
		}
		categories, _ := repo.ListCategories(r.Context())
		h.render.HTML(w, r, "recipe_form.html", map[string]any{
			"Error":      errMsg,
			"Categories": categories,
			"Input":      params,
		})
		return
	}

	logAudit(r.Context(), pool, r, "create", "recipe", item.ID, nil, marshalAudit(item))
	_ = repo.SnapshotRecipe(r.Context(), item.ID, "Recipe created")

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+item.ID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+item.ID.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	item, err := repo.GetRecipeByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	recipeIngs, _ := repo.GetRecipeIngredients(r.Context(), id)
	utilityCosts, _ := repo.GetUtilityCosts(r.Context(), id)

	allIngredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	alertCounts, _ := ingredientRepo.GetUnreadAlertsByIngredient(r.Context())
	unitList, _ := ingredientRepo.ListUnits(r.Context())

	// Shared utility costs: full tenant list + which ones are linked.
	ucRepo := repository.NewUtilityCostRepo(pool)
	allUtilityCosts, _ := ucRepo.List(r.Context(), false)
	linkedIDs, _ := repo.GetLinkedUtilityCostIDs(r.Context(), id)

	utilityExtras, _ := repo.GetUtilityExtras(r.Context(), id)
	costHistory, _ := repo.GetRecipeCostHistory(r.Context(), id, 100)

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
	item.UtilityExtras = utilityExtras
	item.TotalCost = calculateTotalCost(recipeIngs, utilityCosts)
	if item.Yield < 1 {
		item.Yield = 1
	}
	item.CostPerPortion = item.TotalCost / float64(item.Yield)
	if item.SellingPrice > 0 {
		item.CostMargin = ((item.SellingPrice - item.CostPerPortion) / item.SellingPrice) * 100
		item.NetProfit = item.SellingPrice - item.CostPerPortion
	}

	var utilityTotal float64
	for _, u := range utilityCosts {
		utilityTotal += u.Cost
	}

	h.render.HTML(w, r, "recipe_detail.html", map[string]any{
		"Item":                 item,
		"AllIngredients":       allIngredients,
		"AlertCounts":          alertCounts,
		"Units":                unitList,
		"AllUtilityCosts":      allUtilityCosts,
		"LinkedUtilityCostIDs": linkedIDs,
		"CostHistory":          costHistory,
		"UtilityTotal":         utilityTotal,
		"Title":                item.Name,
	})
}

func (h *RecipeHandler) showEdit(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	item, err := repo.GetRecipeByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	categories, _ := repo.ListCategories(r.Context())

	h.render.HTML(w, r, "recipe_form.html", map[string]any{
		"Item":       item,
		"Categories": categories,
		"Title":      "Edit " + item.Name,
		"IsEdit":     true,
	})
}

func (h *RecipeHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Request too large", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	var catID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			catID = &parsed
		}
	}

	// Status, preparation notes and allergens are edited outside the main form
	// (see /recipes/{id}/prep-details and status toggles on the detail page).
	existing, err := repo.GetRecipeByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	// Handle image upload.
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
	} else if err != http.ErrMissingFile {
		slog.Error("form file error", "error", err)
	}

	// Preserve existing image if no new upload.
	if imagePath == "" {
		imagePath = r.FormValue("existing_image_path")
	}

	params := repository.CreateRecipeParams{
		CategoryID:       catID,
		Name:             strings.TrimSpace(r.FormValue("name")),
		Description:      strings.TrimSpace(r.FormValue("description")),
		ImagePath:        imagePath,
		SellingPrice:     parseFloat(r.FormValue("selling_price")),
		Status:           existing.Status,
		PreparationNotes: existing.PreparationNotes,
		Allergens:        existing.Allergens,
		Yield:            parseYield(r.FormValue("yield")),
		YieldUnit:        strings.TrimSpace(r.FormValue("yield_unit")),
	}

	if err := repo.UpdateRecipe(r.Context(), id, params); err != nil {
		errMsg := "Failed to update"
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "idx_menu_items_unique_name") {
			errMsg = "A recipe with this name already exists"
		} else {
			slog.Error("update recipe", "error", err)
		}
		http.Error(w, errMsg, http.StatusBadRequest)
		return
	}

	newRecipe, _ := repo.GetRecipeByID(r.Context(), id)
	logAudit(r.Context(), pool, r, "update", "recipe", id, marshalAudit(existing), marshalAudit(newRecipe))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+id.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) updatePrepDetails(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	notes := strings.TrimSpace(r.FormValue("preparation_notes"))
	allergens := splitAndTrim(r.FormValue("allergens"))

	if err := repo.UpdatePrepDetails(r.Context(), id, notes, allergens); err != nil {
		slog.Error("update prep details", "error", err)
		http.Error(w, "Failed to update", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+id.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	oldRecipe, _ := repo.GetRecipeByID(r.Context(), id)

	if err := repo.DeleteRecipe(r.Context(), id); err != nil {
		http.Error(w, "Failed to delete", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "delete", "recipe", id, marshalAudit(oldRecipe), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes", http.StatusSeeOther)
}

func (h *RecipeHandler) toggleStatus(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	recipe, err := repo.GetRecipeByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	newStatus := "active"
	if recipe.Status == "active" {
		newStatus = "draft"
	}

	if err := repo.UpdateStatus(r.Context(), id, newStatus); err != nil {
		slog.Error("toggle recipe status", "error", err)
		http.Error(w, "Failed to update status", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "update", "recipe", id, marshalAudit(recipe), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+id.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) addIngredient(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	menuItemID, _ := uuid.Parse(r.PathValue("id"))
	ingredientID, _ := uuid.Parse(r.FormValue("ingredient_id"))
	qty := parseFloat(r.FormValue("quantity"))
	ingType := r.FormValue("ingredient_type")
	if ingType == "" {
		ingType = "primary"
	}

	var displayUnitID *uuid.UUID
	if quIDStr := r.FormValue("quantity_unit_id"); quIDStr != "" {
		if quID, err := uuid.Parse(quIDStr); err == nil {
			displayUnitID = &quID
			ing, err := ingredientRepo.GetByID(r.Context(), ingredientID)
			if err != nil || ing.Unit == nil {
				http.Error(w, "Ingredient not found", http.StatusBadRequest)
				return
			}
			if quID != ing.UnitID {
				qUnit, err := ingredientRepo.GetUnitByID(r.Context(), quID)
				if err != nil {
					http.Error(w, "Invalid quantity unit", http.StatusBadRequest)
					return
				}
				converted, err := units.ConvertQuantity(qty, qUnit, ing.Unit)
				if err != nil {
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}
				qty = converted
			}
		}
	}

	if err := repo.AddRecipeIngredient(r.Context(), menuItemID, ingredientID, qty, ingType, "", displayUnitID); err != nil {
		slog.Error("add recipe ingredient", "error", err)
		http.Error(w, "Failed to add ingredient", http.StatusInternalServerError)
		return
	}

	ing, _ := ingredientRepo.GetByID(r.Context(), ingredientID)
	ingName := "ingredient"
	if ing != nil {
		ingName = ing.Name
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("+%s added", ingName))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+menuItemID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+menuItemID.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) updateIngredient(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	menuItemID, _ := uuid.Parse(r.PathValue("id"))
	riID, _ := uuid.Parse(r.PathValue("riId"))
	qty := parseFloat(r.FormValue("quantity"))
	ingType := r.FormValue("ingredient_type")

	ri, err := repo.GetRecipeIngredientByID(r.Context(), riID)
	if err != nil {
		http.Error(w, "Recipe ingredient not found", http.StatusNotFound)
		return
	}

	if ingType == "" {
		ingType = ri.IngredientType
	}

	var displayUnitID *uuid.UUID
	if quIDStr := r.FormValue("quantity_unit_id"); quIDStr != "" {
		if quID, err := uuid.Parse(quIDStr); err == nil {
			displayUnitID = &quID
			if quID != ri.Ingredient.UnitID {
				qUnit, err := ingredientRepo.GetUnitByID(r.Context(), quID)
				if err != nil {
					http.Error(w, "Invalid quantity unit", http.StatusBadRequest)
					return
				}
				converted, err := units.ConvertQuantity(qty, qUnit, ri.Ingredient.Unit)
				if err != nil {
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}
				qty = converted
			}
		}
	}

	if err := repo.UpdateRecipeIngredient(r.Context(), riID, qty, ingType, displayUnitID); err != nil {
		slog.Error("update recipe ingredient", "error", err)
		http.Error(w, "Failed to update ingredient", http.StatusInternalServerError)
		return
	}

	ingName := "ingredient"
	if ri.Ingredient != nil && ri.Ingredient.Name != "" {
		ingName = ri.Ingredient.Name
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("%s quantity updated", ingName))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+menuItemID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+menuItemID.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) removeIngredient(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	menuItemID, _ := uuid.Parse(r.PathValue("id"))
	riID, _ := uuid.Parse(r.PathValue("riId"))

	// Capture name BEFORE deletion for the history reason.
	var ingName string
	if ri, _ := repo.GetRecipeIngredientByID(r.Context(), riID); ri != nil && ri.Ingredient != nil {
		ingName = ri.Ingredient.Name
	}

	if err := repo.RemoveRecipeIngredient(r.Context(), riID); err != nil {
		http.Error(w, "Failed to remove", http.StatusInternalServerError)
		return
	}

	if ingName == "" {
		ingName = "ingredient"
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("-%s removed", ingName))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+menuItemID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+menuItemID.String(), http.StatusSeeOther)
}

// toggleUtilityCost links or unlinks a shared utility cost to a recipe based
// on the `linked` form value ("true" links, anything else unlinks). Used by
// the checkbox picker on the recipe detail page.
func (h *RecipeHandler) toggleUtilityCost(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	menuItemID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	ucID, err := uuid.Parse(r.PathValue("ucId"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	linked := r.FormValue("linked") == "true"
	name, _ := repo.GetUtilityCostNameByID(r.Context(), ucID)

	if linked {
		if err := repo.LinkUtilityCost(r.Context(), menuItemID, ucID); err != nil {
			http.Error(w, "Failed to link cost", http.StatusInternalServerError)
			return
		}
		_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("+%s linked", name))
	} else {
		if err := repo.UnlinkUtilityCost(r.Context(), menuItemID, ucID); err != nil {
			http.Error(w, "Failed to unlink cost", http.StatusInternalServerError)
			return
		}
		_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("-%s unlinked", name))
	}

	// HX-Refresh reloads the page so Total, margin/profit cards, and the
	// cost-history section all reflect the new link state.
	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Refresh", "true")
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *RecipeHandler) addUtilityExtra(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}
	menuItemID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	cost := parseFloat(r.FormValue("cost"))

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	if _, err := repo.AddUtilityExtra(r.Context(), menuItemID, name, cost); err != nil {
		http.Error(w, "Failed to add extra cost", http.StatusInternalServerError)
		return
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("+%s %.2f added", name, cost))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+menuItemID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+menuItemID.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) removeUtilityExtra(w http.ResponseWriter, r *http.Request) {
	menuItemID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	eid, err := uuid.Parse(r.PathValue("eid"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	_, name, err := repo.RemoveUtilityExtra(r.Context(), eid)
	if err != nil {
		http.Error(w, "Failed to remove extra cost", http.StatusInternalServerError)
		return
	}
	_ = repo.SnapshotRecipe(r.Context(), menuItemID, fmt.Sprintf("-%s removed", name))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/recipes/"+menuItemID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/recipes/"+menuItemID.String(), http.StatusSeeOther)
}

func (h *RecipeHandler) createCategory(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewRecipeRepo(pool)

	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Category name is required", http.StatusBadRequest)
		return
	}

	sortOrder := int(parseFloat(r.FormValue("sort_order")))

	_, err := repo.CreateCategory(r.Context(), name, sortOrder)
	if err != nil {
		slog.Error("create category", "error", err)
		http.Error(w, "Failed to create category", http.StatusInternalServerError)
		return
	}

	referer := r.Header.Get("Referer")
	if referer == "" {
		referer = "/recipes/new"
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", referer)
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, referer, http.StatusSeeOther)
}

func calculateTotalCost(ingredients []model.RecipeIngredient, utilities []model.RecipeUtilityCost) float64 {
	total := 0.0
	for _, ri := range ingredients {
		total += ri.LineCost
	}
	for _, uc := range utilities {
		total += uc.Cost
	}
	return total
}

func splitAndTrim(s string) []string {
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
