package handler

import (
	"fmt"
	"log/slog"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/units"
	"searlo-cafe/internal/storage"

	"github.com/google/uuid"
)

type IngredientHandler struct {
	render *Renderer
	store  *storage.ImageStore
}

func NewIngredientHandler(render *Renderer, store *storage.ImageStore) *IngredientHandler {
	return &IngredientHandler{render: render, store: store}
}

func (h *IngredientHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /ingredients", wrap(h.list, "ingredients", "read"))
	mux.Handle("GET /ingredients/new", wrap(h.showCreate, "ingredients", "create"))
	mux.Handle("POST /ingredients", wrap(h.create, "ingredients", "create"))
	mux.Handle("GET /ingredients/categories", wrap(h.listCategories, "ingredients", "read"))
	mux.Handle("POST /ingredients/categories", wrap(h.createCategory, "ingredients", "create"))
	mux.Handle("PUT /ingredients/categories/{id}", wrap(h.updateCategory, "ingredients", "update"))
	mux.Handle("DELETE /ingredients/categories/{id}", wrap(h.deleteCategory, "ingredients", "delete"))
	mux.Handle("GET /ingredients/{id}", wrap(h.show, "ingredients", "read"))
	mux.Handle("GET /ingredients/{id}/edit", wrap(h.showEdit, "ingredients", "update"))
	mux.Handle("PUT /ingredients/{id}", wrap(h.update, "ingredients", "update"))
	mux.Handle("DELETE /ingredients/{id}", wrap(h.delete, "ingredients", "delete"))
	mux.Handle("GET /ingredients/{id}/history", wrap(h.history, "ingredients", "read"))
	mux.Handle("GET /ingredients/{id}/recipes", wrap(h.recipes, "ingredients", "read"))
	mux.Handle("POST /ingredients/{id}/adjust-stock", wrap(h.adjustStock, "ingredients", "update"))
	mux.Handle("GET /ingredients/cost-trends", wrap(h.costTrends, "ingredients", "read"))
}

func (h *IngredientHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	q := r.URL.Query()
	search := q.Get("search")
	categoryIDStr := q.Get("category_id")
	sortBy := q.Get("sort")
	stockFilter := q.Get("stock")

	var categoryID *uuid.UUID
	if categoryIDStr != "" {
		if parsed, err := uuid.Parse(categoryIDStr); err == nil {
			categoryID = &parsed
		}
	}

	ingredients, err := repo.List(r.Context(), search, categoryID, sortBy, stockFilter)
	if err != nil {
		slog.Error("list ingredients", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	units, _ := repo.ListUnits(r.Context())
	recipeCounts, _ := repo.GetRecipeCountsByIngredient(r.Context())
	alertCounts, _ := repo.GetUnreadAlertsByIngredient(r.Context())
	categories, _ := repo.ListCategories(r.Context())
	categoryCounts, _ := repo.GetIngredientCountsByCategory(r.Context())

	h.render.HTML(w, r, "ingredients.html", map[string]any{
		"Ingredients":          ingredients,
		"Units":                units,
		"RecipeCounts":         recipeCounts,
		"AlertCounts":          alertCounts,
		"IngredientCategories": categories,
		"CategoryCounts":       categoryCounts,
		"Filters": map[string]string{
			"search":      search,
			"category_id": categoryIDStr,
			"sort":        sortBy,
			"stock":       stockFilter,
		},
		"Title": "Ingredients",
	})
}

func (h *IngredientHandler) showCreate(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)
	units, _ := repo.ListUnits(r.Context())
	categories, _ := repo.ListCategories(r.Context())

	h.render.HTML(w, r, "ingredient_form.html", map[string]any{
		"Units":      units,
		"Categories": categories,
		"SavedName":  r.URL.Query().Get("saved"),
		"Title":      "Add Ingredient",
	})
}

func (h *IngredientHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Request too large", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	unitID, err := uuid.Parse(r.FormValue("unit_id"))
	if err != nil {
		http.Error(w, "Invalid unit", http.StatusBadRequest)
		return
	}

	var imagePath string
	file, header, fileErr := r.FormFile("image")
	if fileErr == nil {
		defer file.Close()
		if h.store != nil {
			orgDB := middleware.GetOrgDB(r.Context())
			key, uploadErr := h.store.Upload(r.Context(), orgDB, "ingredients", file, header.Filename)
			if uploadErr != nil {
				slog.Error("ingredient image upload failed", "error", uploadErr)
			} else {
				imagePath = key
			}
		}
	} else if fileErr != http.ErrMissingFile {
		slog.Error("form file error", "error", fileErr)
	}

	var categoryID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			categoryID = &parsed
		}
	}

	params := repository.CreateIngredientParams{
		Name:                 strings.TrimSpace(r.FormValue("name")),
		Description:          strings.TrimSpace(r.FormValue("description")),
		ImagePath:            imagePath,
		UnitID:               unitID,
		CurrentStock:         parseFloat(r.FormValue("current_stock")),
		CurrentCostPerUnit:   parseFloat(r.FormValue("current_cost_per_unit")),
		PriceAlertPercentage: parseFloat(r.FormValue("price_alert_percentage")),
		CategoryID:           categoryID,
	}

	if threshold := r.FormValue("low_stock_threshold"); threshold != "" {
		v := parseFloat(threshold)
		params.LowStockThreshold = &v
	}

	if params.PriceAlertPercentage == 0 {
		params.PriceAlertPercentage = 10.0
	}

	// Purchase calculator: compute cost_per_unit from purchase fields.
	if pQty := parseFloat(r.FormValue("purchase_qty")); pQty > 0 {
		pPrice := parseFloat(r.FormValue("purchase_price"))
		pUnitIDStr := r.FormValue("purchase_unit_id")
		if pPrice > 0 && pUnitIDStr != "" {
			if pUnitID, err := uuid.Parse(pUnitIDStr); err == nil {
				baseUnit, _ := repo.GetUnitByID(r.Context(), unitID)
				purchaseUnit, _ := repo.GetUnitByID(r.Context(), pUnitID)
				if baseUnit != nil && purchaseUnit != nil {
					if cost, err := units.ConvertPrice(pPrice/pQty, purchaseUnit, baseUnit); err == nil {
						params.CurrentCostPerUnit = cost
					}
				}
			}
		}
	}

	// Convert initial stock if entered in a different unit.
	if stockUnitStr := r.FormValue("stock_unit_id"); stockUnitStr != "" {
		if stockUnitID, err := uuid.Parse(stockUnitStr); err == nil && stockUnitID != unitID {
			stockUnit, _ := repo.GetUnitByID(r.Context(), stockUnitID)
			baseUnit, _ := repo.GetUnitByID(r.Context(), unitID)
			if stockUnit != nil && baseUnit != nil {
				if converted, err := units.ConvertQuantity(params.CurrentStock, stockUnit, baseUnit); err == nil {
					params.CurrentStock = converted
				}
			}
		}
	}

	ingredient, err := repo.Create(r.Context(), params)
	if err != nil {
		slog.Error("create ingredient", "error", err)
		units, _ := repo.ListUnits(r.Context())
		categories, _ := repo.ListCategories(r.Context())
		h.render.HTML(w, r, "ingredient_form.html", map[string]any{
			"Error":      "Failed to create ingredient",
			"Units":      units,
			"Categories": categories,
			"Input":      params,
		})
		return
	}

	logAudit(r.Context(), pool, r, "create", "ingredient", ingredient.ID, nil, marshalAudit(ingredient))

	dest := "/ingredients"
	if r.FormValue("action") == "continue" {
		dest = "/ingredients/new?saved=" + url.QueryEscape(ingredient.Name)
	}
	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", dest)
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, dest, http.StatusSeeOther)
}

func (h *IngredientHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	ing, err := repo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	history, _ := repo.GetPriceHistory(r.Context(), id)
	unitList, _ := repo.ListUnits(r.Context())

	billRepo := repository.NewBillRepo(pool)
	recentBills, _ := billRepo.GetRecentBillsForIngredient(r.Context(), id, 10)

	h.render.HTML(w, r, "ingredient_detail.html", map[string]any{
		"Ingredient":  ing,
		"History":     history,
		"Units":       unitList,
		"RecentBills": recentBills,
		"Title":       ing.Name,
	})
}

func (h *IngredientHandler) showEdit(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	ing, err := repo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	units, _ := repo.ListUnits(r.Context())
	categories, _ := repo.ListCategories(r.Context())

	h.render.HTML(w, r, "ingredient_form.html", map[string]any{
		"Ingredient": ing,
		"Units":      units,
		"Categories": categories,
		"Title":      "Edit " + ing.Name,
		"IsEdit":     true,
	})
}

func (h *IngredientHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Request too large", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	unitID, err := uuid.Parse(r.FormValue("unit_id"))
	if err != nil {
		http.Error(w, "Invalid unit", http.StatusBadRequest)
		return
	}

	// Handle image upload.
	var imagePath string
	file, header, fileErr := r.FormFile("image")
	if fileErr == nil {
		defer file.Close()
		if h.store != nil {
			orgDB := middleware.GetOrgDB(r.Context())
			key, uploadErr := h.store.Upload(r.Context(), orgDB, "ingredients", file, header.Filename)
			if uploadErr != nil {
				slog.Error("ingredient image upload failed", "error", uploadErr)
			} else {
				imagePath = key
			}
		}
	} else if fileErr != http.ErrMissingFile {
		slog.Error("form file error", "error", fileErr)
	}

	// Preserve existing image if no new upload.
	if imagePath == "" {
		imagePath = r.FormValue("existing_image_path")
	}

	var categoryID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			categoryID = &parsed
		}
	}

	params := repository.CreateIngredientParams{
		Name:                 strings.TrimSpace(r.FormValue("name")),
		Description:          strings.TrimSpace(r.FormValue("description")),
		ImagePath:            imagePath,
		UnitID:               unitID,
		PriceAlertPercentage: parseFloat(r.FormValue("price_alert_percentage")),
		CategoryID:           categoryID,
	}

	if threshold := r.FormValue("low_stock_threshold"); threshold != "" {
		v := parseFloat(threshold)
		params.LowStockThreshold = &v
	}

	oldIngredient, _ := repo.GetByID(r.Context(), id)

	if err := repo.Update(r.Context(), id, params); err != nil {
		slog.Error("update ingredient", "error", err)
		http.Error(w, "Failed to update", http.StatusInternalServerError)
		return
	}

	if oldIngredient != nil && oldIngredient.Unit != nil {
		var newCost float64
		var costResolved bool

		// Purchase calculator takes priority.
		if pQty := parseFloat(r.FormValue("purchase_qty")); pQty > 0 {
			pPrice := parseFloat(r.FormValue("purchase_price"))
			pUnitIDStr := r.FormValue("purchase_unit_id")
			if pPrice > 0 && pUnitIDStr != "" {
				if pUnitID, err := uuid.Parse(pUnitIDStr); err == nil {
					purchaseUnit, _ := repo.GetUnitByID(r.Context(), pUnitID)
					if purchaseUnit != nil {
						if cost, err := units.ConvertPrice(pPrice/pQty, purchaseUnit, oldIngredient.Unit); err == nil {
							newCost = cost
							costResolved = true
						}
					}
				}
			}
		}

		if !costResolved {
			newCost = parseFloat(r.FormValue("current_cost_per_unit"))
			if costUnitIDStr := r.FormValue("cost_unit_id"); costUnitIDStr != "" {
				if costUnitID, err := uuid.Parse(costUnitIDStr); err == nil && costUnitID != oldIngredient.UnitID {
					costUnit, err := repo.GetUnitByID(r.Context(), costUnitID)
					if err != nil {
						http.Error(w, "Invalid cost unit", http.StatusBadRequest)
						return
					}
					converted, err := units.ConvertPrice(newCost, costUnit, oldIngredient.Unit)
					if err != nil {
						http.Error(w, err.Error(), http.StatusBadRequest)
						return
					}
					newCost = converted
				}
			}
		}
		if newCost != oldIngredient.CurrentCostPerUnit {
			if err := repo.RecordPriceChange(r.Context(), id, oldIngredient.CurrentCostPerUnit, newCost, "manual", nil); err != nil {
				slog.Error("record manual price change", "error", err)
			}
			if err := repo.UpdatePrice(r.Context(), id, newCost); err != nil {
				slog.Error("update ingredient price", "error", err)
				http.Error(w, "Failed to update price", http.StatusInternalServerError)
				return
			}
			recipeRepo := repository.NewRecipeRepo(pool)
			reason := fmt.Sprintf("%s price %.2f → %.2f", oldIngredient.Name, oldIngredient.CurrentCostPerUnit, newCost)
			if err := recipeRepo.SnapshotRecipesUsingIngredient(r.Context(), id, reason); err != nil {
				slog.Error("snapshot recipes using ingredient", "error", err)
			}
		}
	}

	newIngredient, _ := repo.GetByID(r.Context(), id)
	logAudit(r.Context(), pool, r, "update", "ingredient", id, marshalAudit(oldIngredient), marshalAudit(newIngredient))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/ingredients/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/ingredients/"+id.String(), http.StatusSeeOther)
}

func (h *IngredientHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	oldIngredient, _ := repo.GetByID(r.Context(), id)

	if err := repo.Delete(r.Context(), id); err != nil {
		slog.Error("delete ingredient", "error", err)
		http.Error(w, "Failed to delete", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "delete", "ingredient", id, marshalAudit(oldIngredient), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/ingredients")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/ingredients", http.StatusSeeOther)
}

func (h *IngredientHandler) adjustStock(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	ing, err := repo.GetByID(r.Context(), id)
	if err != nil || ing.Unit == nil {
		http.Error(w, "Ingredient not found", http.StatusBadRequest)
		return
	}

	qty := parseFloat(r.FormValue("quantity"))
	if qty <= 0 {
		http.Error(w, "Quantity must be positive", http.StatusBadRequest)
		return
	}

	if quIDStr := r.FormValue("quantity_unit_id"); quIDStr != "" {
		if quID, err := uuid.Parse(quIDStr); err == nil && quID != ing.UnitID {
			qUnit, err := repo.GetUnitByID(r.Context(), quID)
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

	direction := r.FormValue("direction")
	if direction == "remove" {
		qty = -qty
	} else if direction != "add" {
		http.Error(w, "Invalid direction", http.StatusBadRequest)
		return
	}

	notes := strings.TrimSpace(r.FormValue("notes"))

	if err := repo.UpdateStock(r.Context(), id, qty); err != nil {
		slog.Error("adjust stock", "error", err)
		http.Error(w, "Failed to adjust stock", http.StatusInternalServerError)
		return
	}
	if err := stockRepo.RecordMovement(r.Context(), nil, id, qty, "adjustment", "manual", nil, notes, userID); err != nil {
		slog.Error("record adjustment movement", "error", err)
	}

	logAudit(r.Context(), pool, r, "update", "ingredient", id, marshalAudit(ing), marshalAudit(map[string]any{"adjustment": qty, "notes": notes}))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/ingredients/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/ingredients/"+id.String(), http.StatusSeeOther)
}

func (h *IngredientHandler) history(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	history, err := repo.GetPriceHistory(r.Context(), id)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.Fragment(w, r, "price_history.html", map[string]any{"History": history})
}

func (h *IngredientHandler) recipes(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	ing, err := repo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	recipes, _ := repo.GetRecipesForIngredient(r.Context(), id)

	h.render.Fragment(w, r, "ingredient_recipes.html", map[string]any{
		"Ingredient": ing,
		"Recipes":    recipes,
	})
}

func (h *IngredientHandler) listCategories(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	categories, err := repo.ListCategories(r.Context())
	if err != nil {
		slog.Error("list ingredient categories", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	counts, _ := repo.GetIngredientCountsByCategory(r.Context())

	h.render.HTML(w, r, "ingredient_categories.html", map[string]any{
		"Categories":     categories,
		"CategoryCounts": counts,
		"Title":          "Ingredient Categories",
	})
}

func (h *IngredientHandler) updateCategory(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Category name is required", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	if err := repo.UpdateCategoryName(r.Context(), id, name); err != nil {
		slog.Error("update ingredient category", "error", err)
		http.Error(w, "Failed to update category", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/ingredients/categories")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/ingredients/categories", http.StatusSeeOther)
}

func (h *IngredientHandler) deleteCategory(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	if err := repo.DeleteCategory(r.Context(), id); err != nil {
		slog.Error("delete ingredient category", "error", err)
		http.Error(w, "Failed to delete category", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/ingredients/categories")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/ingredients/categories", http.StatusSeeOther)
}

func (h *IngredientHandler) createCategory(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Category name is required", http.StatusBadRequest)
		return
	}

	nextSortOrder, _ := repo.NextCategorySortOrder(r.Context())

	if _, err := repo.CreateCategory(r.Context(), name, nextSortOrder); err != nil {
		slog.Error("create ingredient category", "error", err)
		http.Error(w, "Failed to create category", http.StatusInternalServerError)
		return
	}

	referer := r.Header.Get("Referer")
	if referer == "" {
		referer = "/ingredients/new"
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", referer)
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, referer, http.StatusSeeOther)
}

func (h *IngredientHandler) costTrends(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	ingredients, err := repo.List(r.Context(), "", nil, "", "")
	if err != nil {
		slog.Error("list ingredients for cost trends", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	type ingredientTrend struct {
		ID               uuid.UUID
		Name             string
		Unit             string
		CurrentCost      float64
		History          []model.IngredientPriceHistory
		LatestChange     float64
		LatestChangeDate string
	}

	var trends []ingredientTrend
	for _, ing := range ingredients {
		history, _ := repo.GetPriceHistory(r.Context(), ing.ID)
		unitAbbr := ""
		if ing.Unit != nil {
			unitAbbr = ing.Unit.Abbreviation
		}
		t := ingredientTrend{
			ID:          ing.ID,
			Name:        ing.Name,
			Unit:        unitAbbr,
			CurrentCost: ing.CurrentCostPerUnit,
			History:     history,
		}
		if len(history) > 0 {
			t.LatestChange = history[0].ChangePercentage
			t.LatestChangeDate = history[0].RecordedAt.Format("Jan 02, 2006")
		}
		trends = append(trends, t)
	}

	h.render.HTML(w, r, "cost_trends.html", map[string]any{
		"Trends": trends,
		"Title":  "Ingredient Cost Trends",
	})
}

func parseFloat(s string) float64 {
	v, _ := strconv.ParseFloat(strings.TrimSpace(s), 64)
	return v
}

// parseYield parses a recipe yield (integer portion count). Blanks, zero, or
// negatives normalize to 1 so a missing/invalid form value never produces a
// divide-by-zero downstream.
func parseYield(s string) int {
	v, _ := strconv.Atoi(strings.TrimSpace(s))
	if v < 1 {
		v = 1
	}
	return v
}
