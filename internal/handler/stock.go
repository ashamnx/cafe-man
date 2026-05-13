package handler

import (
	"log/slog"
	"net/http"
	"strconv"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/units"

	"github.com/google/uuid"
)

type StockHandler struct {
	render *Renderer
}

func NewStockHandler(render *Renderer) *StockHandler {
	return &StockHandler{render: render}
}

func (h *StockHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	// Sales
	mux.Handle("GET /sales", wrap(h.listSales, "sales", "read"))
	mux.Handle("GET /sales/new", wrap(h.showCreateSale, "sales", "create"))
	mux.Handle("POST /sales", wrap(h.createSale, "sales", "create"))
	mux.Handle("GET /sales/{id}", wrap(h.showSale, "sales", "read"))
	mux.Handle("POST /sales/{id}/items", wrap(h.addSaleItem, "sales", "update"))
	mux.Handle("DELETE /sales/{id}/items/{itemId}", wrap(h.removeSaleItem, "sales", "update"))
	mux.Handle("POST /sales/{id}/apply", wrap(h.applySale, "sales", "update"))
	mux.Handle("DELETE /sales/{id}", wrap(h.deleteSale, "sales", "delete"))

	// Wastage
	mux.Handle("GET /wastage", wrap(h.listWastage, "wastage", "read"))
	mux.Handle("GET /wastage/new", wrap(h.showCreateWastage, "wastage", "create"))
	mux.Handle("POST /wastage", wrap(h.createWastage, "wastage", "create"))

	// Stock Movements
	mux.Handle("GET /stock-movements", wrap(h.listMovements, "stock_movements", "read"))
}

// ---------------------------------------------------------------------------
// Sales
// ---------------------------------------------------------------------------

func (h *StockHandler) listSales(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewStockRepo(pool)

	entries, err := repo.ListSaleEntries(r.Context())
	if err != nil {
		slog.Error("list sale entries", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.HTML(w, r, "sales.html", map[string]any{
		"Entries": entries,
		"Title":   "Sales",
	})
}

func (h *StockHandler) showCreateSale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	recipeRepo := repository.NewRecipeRepo(pool)

	items, err := recipeRepo.ListRecipes(r.Context(), "", "", "active", "name", nil)
	if err != nil {
		slog.Error("list menu items", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.HTML(w, r, "sale_form.html", map[string]any{
		"MenuItems": items,
		"Title":     "Record Sales",
	})
}

func (h *StockHandler) createSale(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	recipeRepo := repository.NewRecipeRepo(pool)
	userID := middleware.GetUserID(r.Context())

	saleDate := r.FormValue("sale_date")
	notes := r.FormValue("notes")

	entry, err := stockRepo.CreateSaleEntry(r.Context(), saleDate, notes, userID)
	if err != nil {
		slog.Error("create sale entry", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "create", "sale_entry", entry.ID, nil, marshalAudit(entry))

	// Add line items from form arrays.
	menuItemIDs := r.Form["menu_item_id"]
	quantities := r.Form["quantity"]

	for i := range menuItemIDs {
		if i >= len(quantities) {
			break
		}
		miID, err := uuid.Parse(menuItemIDs[i])
		if err != nil || menuItemIDs[i] == "" {
			continue
		}
		qty, err := strconv.Atoi(quantities[i])
		if err != nil || qty <= 0 {
			continue
		}

		// Get selling price for snapshot.
		mi, err := recipeRepo.GetRecipeByID(r.Context(), miID)
		var price float64
		if err == nil {
			price = mi.SellingPrice
		}

		stockRepo.AddSaleEntryItem(r.Context(), entry.ID, miID, qty, price)
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/sales/"+entry.ID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/sales/"+entry.ID.String(), http.StatusSeeOther)
}

func (h *StockHandler) showSale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	entry, err := stockRepo.GetSaleEntryByID(r.Context(), id)
	if err != nil {
		slog.Error("get sale entry", "error", err)
		http.NotFound(w, r)
		return
	}

	data := map[string]any{
		"Entry": entry,
		"Title": "Sale Entry",
	}

	// If applied, also fetch deductions.
	if entry.Status == "applied" {
		deductions, _ := stockRepo.GetSaleEntryDeductions(r.Context(), id)
		data["Deductions"] = deductions
	}

	// If draft, provide menu items for adding more items.
	if entry.Status == "draft" {
		recipeRepo := repository.NewRecipeRepo(pool)
		menuItems, _ := recipeRepo.ListRecipes(r.Context(), "", "", "active", "name", nil)
		data["MenuItems"] = menuItems
	}

	h.render.HTML(w, r, "sale_detail.html", data)
}

func (h *StockHandler) addSaleItem(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	recipeRepo := repository.NewRecipeRepo(pool)

	saleEntryID, _ := uuid.Parse(r.PathValue("id"))
	menuItemID, _ := uuid.Parse(r.FormValue("menu_item_id"))
	qty, _ := strconv.Atoi(r.FormValue("quantity"))
	if qty <= 0 {
		http.Error(w, "Quantity must be positive", http.StatusBadRequest)
		return
	}

	mi, err := recipeRepo.GetRecipeByID(r.Context(), menuItemID)
	var price float64
	if err == nil {
		price = mi.SellingPrice
	}

	if err := stockRepo.AddSaleEntryItem(r.Context(), saleEntryID, menuItemID, qty, price); err != nil {
		slog.Error("add sale item", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/sales/"+saleEntryID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/sales/"+saleEntryID.String(), http.StatusSeeOther)
}

func (h *StockHandler) removeSaleItem(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	itemID, _ := uuid.Parse(r.PathValue("itemId"))
	saleEntryID := r.PathValue("id")

	if err := stockRepo.DeleteSaleEntryItem(r.Context(), itemID); err != nil {
		slog.Error("remove sale item", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/sales/"+saleEntryID)
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/sales/"+saleEntryID, http.StatusSeeOther)
}

func (h *StockHandler) applySale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	saleEntryID, _ := uuid.Parse(r.PathValue("id"))
	oldEntry, _ := stockRepo.GetSaleEntryByID(r.Context(), saleEntryID)

	if err := stockRepo.ApplySaleEntry(r.Context(), saleEntryID, userID); err != nil {
		slog.Error("apply sale entry", "error", err)
		http.Error(w, "Failed to apply: "+err.Error(), http.StatusInternalServerError)
		return
	}

	newEntry, _ := stockRepo.GetSaleEntryByID(r.Context(), saleEntryID)
	logAudit(r.Context(), pool, r, "update", "sale_entry", saleEntryID, marshalAudit(oldEntry), marshalAudit(newEntry))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/sales/"+saleEntryID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/sales/"+saleEntryID.String(), http.StatusSeeOther)
}

func (h *StockHandler) deleteSale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	id, _ := uuid.Parse(r.PathValue("id"))
	oldEntry, _ := stockRepo.GetSaleEntryByID(r.Context(), id)

	stockRepo.DeleteSaleEntry(r.Context(), id)

	logAudit(r.Context(), pool, r, "delete", "sale_entry", id, marshalAudit(oldEntry), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/sales")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/sales", http.StatusSeeOther)
}

// ---------------------------------------------------------------------------
// Wastage
// ---------------------------------------------------------------------------

func (h *StockHandler) listWastage(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	q := r.URL.Query()
	ingredientFilter := q.Get("ingredient")
	typeFilter := q.Get("type")

	records, err := stockRepo.ListWastageRecords(r.Context(), ingredientFilter, typeFilter)
	if err != nil {
		slog.Error("list wastage records", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "name", "")

	h.render.HTML(w, r, "wastage.html", map[string]any{
		"Records":     records,
		"Ingredients": ingredients,
		"Filters": map[string]string{
			"ingredient": ingredientFilter,
			"type":       typeFilter,
		},
		"Title": "Wastage",
	})
}

func (h *StockHandler) showCreateWastage(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	ingredientRepo := repository.NewIngredientRepo(pool)

	ingredients, err := ingredientRepo.List(r.Context(), "", nil, "name", "")
	if err != nil {
		slog.Error("list ingredients", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	units, _ := ingredientRepo.ListUnits(r.Context())

	h.render.HTML(w, r, "wastage_form.html", map[string]any{
		"Ingredients": ingredients,
		"Units":       units,
		"Title":       "Record Wastage",
	})
}

func (h *StockHandler) createWastage(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)
	userID := middleware.GetUserID(r.Context())

	ingredientID, err := uuid.Parse(r.FormValue("ingredient_id"))
	if err != nil {
		http.Error(w, "Invalid ingredient", http.StatusBadRequest)
		return
	}

	quantity, err := strconv.ParseFloat(r.FormValue("quantity"), 64)
	if err != nil || quantity <= 0 {
		http.Error(w, "Quantity must be positive", http.StatusBadRequest)
		return
	}

	if quIDStr := r.FormValue("quantity_unit_id"); quIDStr != "" {
		if quID, err := uuid.Parse(quIDStr); err == nil {
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
				converted, err := units.ConvertQuantity(quantity, qUnit, ing.Unit)
				if err != nil {
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}
				quantity = converted
			}
		}
	}

	wastageType := r.FormValue("wastage_type")
	wastageDate := r.FormValue("wastage_date")
	notes := r.FormValue("notes")

	wastageRecord, err := stockRepo.CreateWastageRecord(r.Context(), ingredientID, quantity, wastageType, wastageDate, notes, userID)
	if err != nil {
		slog.Error("create wastage record", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "create", "wastage", wastageRecord.ID, nil, marshalAudit(wastageRecord))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/wastage")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/wastage", http.StatusSeeOther)
}

// ---------------------------------------------------------------------------
// Stock movements
// ---------------------------------------------------------------------------

func (h *StockHandler) listMovements(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	q := r.URL.Query()
	ingredientFilter := q.Get("ingredient")
	typeFilter := q.Get("type")

	movements, err := stockRepo.ListStockMovements(r.Context(), ingredientFilter, typeFilter, 100)
	if err != nil {
		slog.Error("list stock movements", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "name", "")

	h.render.HTML(w, r, "stock_movements.html", map[string]any{
		"Movements":   movements,
		"Ingredients": ingredients,
		"Filters": map[string]string{
			"ingredient": ingredientFilter,
			"type":       typeFilter,
		},
		"Title": "Stock Movements",
	})
}
