package apihandler

import (
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/units"
	"searlo-cafe/internal/storage"

	"github.com/google/uuid"
)

type IngredientAPIHandler struct {
	store *storage.ImageStore
}

func NewIngredientAPIHandler(store *storage.ImageStore) *IngredientAPIHandler {
	return &IngredientAPIHandler{store: store}
}

func (h *IngredientAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/ingredients", wrap(h.list, "ingredients", "read"))
	mux.Handle("POST /api/v1/ingredients", wrap(h.create, "ingredients", "create"))
	mux.Handle("GET /api/v1/ingredients/cost-trends", wrap(h.costTrends, "ingredients", "read"))
	mux.Handle("GET /api/v1/ingredients/categories", wrap(h.categories, "ingredients", "read"))
	mux.Handle("POST /api/v1/ingredients/categories", wrap(h.createCategory, "ingredients", "create"))
	mux.Handle("GET /api/v1/ingredients/{id}", wrap(h.show, "ingredients", "read"))
	mux.Handle("PUT /api/v1/ingredients/{id}", wrap(h.update, "ingredients", "update"))
	mux.Handle("DELETE /api/v1/ingredients/{id}", wrap(h.delete, "ingredients", "delete"))
	mux.Handle("GET /api/v1/ingredients/{id}/history", wrap(h.history, "ingredients", "read"))
	mux.Handle("GET /api/v1/ingredients/{id}/recipes", wrap(h.recipes, "ingredients", "read"))
	mux.Handle("GET /api/v1/units", wrap(h.units, "ingredients", "read"))
}

func (h *IngredientAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	q := r.URL.Query()
	var categoryID *uuid.UUID
	if cid := q.Get("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			categoryID = &parsed
		}
	}
	ingredients, err := repo.List(r.Context(), q.Get("search"), categoryID, q.Get("sort"), q.Get("stock"))
	if err != nil {
		slog.Error("api: list ingredients", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list ingredients")
		return
	}

	alertCounts, _ := repo.GetUnreadAlertsByIngredient(r.Context())
	recipeCounts, _ := repo.GetRecipeCountsByIngredient(r.Context())

	writeJSON(w, http.StatusOK, map[string]any{
		"ingredients":   ingredients,
		"alert_counts":  alertCounts,
		"recipe_counts": recipeCounts,
	})
}

func (h *IngredientAPIHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	ing, err := repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "ingredient not found")
		return
	}

	history, _ := repo.GetPriceHistory(r.Context(), id)

	writeJSON(w, http.StatusOK, map[string]any{
		"ingredient":    ing,
		"price_history": history,
	})
}

func (h *IngredientAPIHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "request too large")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	unitID, err := uuid.Parse(r.FormValue("unit_id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid unit_id")
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
		CurrentStock:         apiParseFloat(r.FormValue("current_stock")),
		CurrentCostPerUnit:   apiParseFloat(r.FormValue("current_cost_per_unit")),
		PriceAlertPercentage: apiParseFloat(r.FormValue("price_alert_percentage")),
		CategoryID:           categoryID,
	}

	if threshold := r.FormValue("low_stock_threshold"); threshold != "" {
		v := apiParseFloat(threshold)
		params.LowStockThreshold = &v
	}

	if params.PriceAlertPercentage == 0 {
		params.PriceAlertPercentage = 10.0
	}

	if params.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	// Purchase calculator: compute cost_per_unit from purchase fields, and
	// persist the bulk values themselves as defaults for the ingredients list.
	if pQty := apiParseFloat(r.FormValue("purchase_qty")); pQty > 0 {
		pPrice := apiParseFloat(r.FormValue("purchase_price"))
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
				params.PurchaseQty = &pQty
				params.PurchaseUnitID = &pUnitID
				params.PurchasePrice = &pPrice
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

	ing, err := repo.Create(r.Context(), params)
	if err != nil {
		slog.Error("api: create ingredient", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create ingredient")
		return
	}

	// Audit log: create ingredient
	if newJSON, err := json.Marshal(ing); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "create", "ingredient", ing.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, ing)
}

func (h *IngredientAPIHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "request too large")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	unitID, err := uuid.Parse(r.FormValue("unit_id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid unit_id")
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
	}

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
		PriceAlertPercentage: apiParseFloat(r.FormValue("price_alert_percentage")),
		CategoryID:           categoryID,
	}

	if threshold := r.FormValue("low_stock_threshold"); threshold != "" {
		v := apiParseFloat(threshold)
		params.LowStockThreshold = &v
	}

	if pQty := apiParseFloat(r.FormValue("purchase_qty")); pQty > 0 {
		pPrice := apiParseFloat(r.FormValue("purchase_price"))
		if pUnitIDStr := r.FormValue("purchase_unit_id"); pPrice > 0 && pUnitIDStr != "" {
			if pUnitID, err := uuid.Parse(pUnitIDStr); err == nil {
				params.PurchaseQty = &pQty
				params.PurchaseUnitID = &pUnitID
				params.PurchasePrice = &pPrice
			}
		}
	}

	oldIng, _ := repo.GetByID(r.Context(), id)

	if err := repo.Update(r.Context(), id, params); err != nil {
		slog.Error("api: update ingredient", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to update ingredient")
		return
	}

	if oldIng != nil && oldIng.Unit != nil {
		var newCost float64
		var costResolved bool

		// Purchase calculator takes priority.
		if pQty := apiParseFloat(r.FormValue("purchase_qty")); pQty > 0 {
			pPrice := apiParseFloat(r.FormValue("purchase_price"))
			pUnitIDStr := r.FormValue("purchase_unit_id")
			if pPrice > 0 && pUnitIDStr != "" {
				if pUnitID, err := uuid.Parse(pUnitIDStr); err == nil {
					purchaseUnit, _ := repo.GetUnitByID(r.Context(), pUnitID)
					if purchaseUnit != nil {
						if cost, err := units.ConvertPrice(pPrice/pQty, purchaseUnit, oldIng.Unit); err == nil {
							newCost = cost
							costResolved = true
						}
					}
				}
			}
		}

		if !costResolved {
			newCost = apiParseFloat(r.FormValue("current_cost_per_unit"))
			if costUnitIDStr := r.FormValue("cost_unit_id"); costUnitIDStr != "" {
				if costUnitID, err := uuid.Parse(costUnitIDStr); err == nil && costUnitID != oldIng.UnitID {
					costUnit, err := repo.GetUnitByID(r.Context(), costUnitID)
					if err != nil {
						writeError(w, http.StatusBadRequest, "invalid cost_unit_id")
						return
					}
					converted, err := units.ConvertPrice(newCost, costUnit, oldIng.Unit)
					if err != nil {
						writeError(w, http.StatusBadRequest, err.Error())
						return
					}
					newCost = converted
				}
			}
		}
		if newCost != oldIng.CurrentCostPerUnit {
			oldPrice := oldIng.CurrentCostPerUnit
			if err := repo.RecordPriceChange(r.Context(), id, oldPrice, newCost, "manual", nil); err != nil {
				slog.Error("api: record manual price change", "error", err)
			}
			if err := repo.UpdatePrice(r.Context(), id, newCost); err != nil {
				slog.Error("api: update ingredient price", "error", err)
				writeError(w, http.StatusInternalServerError, "failed to update price")
				return
			}
			recipeRepo := repository.NewRecipeRepo(pool)
			reason := fmt.Sprintf("%s price %.2f → %.2f", oldIng.Name, oldPrice, newCost)
			if err := recipeRepo.SnapshotRecipesUsingIngredient(r.Context(), id, reason); err != nil {
				slog.Error("api: snapshot recipes using ingredient", "error", err)
			}
		}
	}

	ing, _ := repo.GetByID(r.Context(), id)

	// Audit log: update ingredient
	oldJSON, _ := json.Marshal(oldIng)
	newJSON, _ := json.Marshal(ing)
	auditRepo := repository.NewAuditRepo(pool)
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "update", "ingredient", id, oldJSON, newJSON, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, ing)
}

func (h *IngredientAPIHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	oldIng, _ := repo.GetByID(r.Context(), id)

	if err := repo.Delete(r.Context(), id); err != nil {
		slog.Error("api: delete ingredient", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to delete ingredient")
		return
	}

	// Audit log: delete ingredient
	if oldJSON, err := json.Marshal(oldIng); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "delete", "ingredient", id, oldJSON, nil, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "deleted"})
}

func (h *IngredientAPIHandler) history(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	history, err := repo.GetPriceHistory(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get price history")
		return
	}

	writeJSON(w, http.StatusOK, history)
}

func (h *IngredientAPIHandler) recipes(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	recipes, err := repo.GetRecipesForIngredient(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get recipes")
		return
	}

	writeJSON(w, http.StatusOK, recipes)
}

func (h *IngredientAPIHandler) costTrends(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	ingredients, err := repo.List(r.Context(), "", nil, "", "")
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get cost trends")
		return
	}

	type trend struct {
		ID          uuid.UUID `json:"id"`
		Name        string    `json:"name"`
		Unit        string    `json:"unit"`
		CurrentCost float64   `json:"current_cost"`
		History     any       `json:"history"`
	}

	var trends []trend
	for _, ing := range ingredients {
		history, _ := repo.GetPriceHistory(r.Context(), ing.ID)
		unitAbbr := ""
		if ing.Unit != nil {
			unitAbbr = ing.Unit.Abbreviation
		}
		trends = append(trends, trend{
			ID:          ing.ID,
			Name:        ing.Name,
			Unit:        unitAbbr,
			CurrentCost: ing.CurrentCostPerUnit,
			History:     history,
		})
	}

	writeJSON(w, http.StatusOK, trends)
}

func (h *IngredientAPIHandler) categories(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	cats, err := repo.ListCategories(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list categories")
		return
	}

	writeJSON(w, http.StatusOK, cats)
}

type createIngredientCategoryRequest struct {
	Name      string `json:"name"`
	SortOrder int    `json:"sort_order"`
}

func (h *IngredientAPIHandler) createCategory(w http.ResponseWriter, r *http.Request) {
	var req createIngredientCategoryRequest
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
	repo := repository.NewIngredientRepo(pool)

	cat, err := repo.CreateCategory(r.Context(), req.Name, req.SortOrder)
	if err != nil {
		slog.Error("api: create ingredient category", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create category")
		return
	}

	writeJSON(w, http.StatusCreated, cat)
}

func (h *IngredientAPIHandler) units(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewIngredientRepo(pool)

	units, err := repo.ListUnits(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to list units")
		return
	}

	writeJSON(w, http.StatusOK, units)
}

func apiParseFloat(s string) float64 {
	v, _ := strconv.ParseFloat(strings.TrimSpace(s), 64)
	return v
}

// apiParseYield parses a recipe yield integer. Blanks/invalid/<1 normalize to 1.
func apiParseYield(s string) int {
	v, _ := strconv.Atoi(strings.TrimSpace(s))
	if v < 1 {
		v = 1
	}
	return v
}
