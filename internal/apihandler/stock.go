package apihandler

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strconv"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
)

type StockAPIHandler struct{}

func NewStockAPIHandler() *StockAPIHandler {
	return &StockAPIHandler{}
}

func (h *StockAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	// Sales
	mux.Handle("GET /api/v1/sales", wrap(h.listSales, "sales", "read"))
	mux.Handle("POST /api/v1/sales", wrap(h.createSale, "sales", "create"))
	mux.Handle("GET /api/v1/sales/{id}", wrap(h.showSale, "sales", "read"))
	mux.Handle("POST /api/v1/sales/{id}/items", wrap(h.addSaleItem, "sales", "update"))
	mux.Handle("DELETE /api/v1/sales/{id}/items/{itemId}", wrap(h.removeSaleItem, "sales", "update"))
	mux.Handle("POST /api/v1/sales/{id}/apply", wrap(h.applySale, "sales", "update"))
	mux.Handle("DELETE /api/v1/sales/{id}", wrap(h.deleteSale, "sales", "delete"))

	// Wastage
	mux.Handle("GET /api/v1/wastage", wrap(h.listWastage, "wastage", "read"))
	mux.Handle("POST /api/v1/wastage", wrap(h.createWastage, "wastage", "create"))

	// Stock Movements
	mux.Handle("GET /api/v1/stock-movements", wrap(h.listMovements, "stock_movements", "read"))
}

// Sales

func (h *StockAPIHandler) listSales(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewStockRepo(pool)

	entries, err := repo.ListSaleEntries(r.Context())
	if err != nil {
		slog.Error("api: list sale entries", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list sales")
		return
	}

	writeJSON(w, http.StatusOK, entries)
}

type createSaleRequest struct {
	SaleDate string `json:"sale_date"`
	Notes    string `json:"notes"`
	Items    []struct {
		MenuItemID string `json:"menu_item_id"`
		Quantity   int    `json:"quantity"`
	} `json:"items"`
}

func (h *StockAPIHandler) createSale(w http.ResponseWriter, r *http.Request) {
	var req createSaleRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	recipeRepo := repository.NewRecipeRepo(pool)
	userID := middleware.GetUserID(r.Context())

	entry, err := stockRepo.CreateSaleEntry(r.Context(), req.SaleDate, req.Notes, userID)
	if err != nil {
		slog.Error("api: create sale entry", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create sale")
		return
	}

	for _, item := range req.Items {
		miID, err := uuid.Parse(item.MenuItemID)
		if err != nil || item.Quantity <= 0 {
			continue
		}
		mi, err := recipeRepo.GetRecipeByID(r.Context(), miID)
		var price float64
		if err == nil {
			price = mi.SellingPrice
		}
		stockRepo.AddSaleEntryItem(r.Context(), entry.ID, miID, item.Quantity, price)
	}

	entry, _ = stockRepo.GetSaleEntryByID(r.Context(), entry.ID)

	// Audit log: create sale entry
	if newJSON, err := json.Marshal(entry); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "create", "sale_entry", entry.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, entry)
}

func (h *StockAPIHandler) showSale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	entry, err := stockRepo.GetSaleEntryByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "sale not found")
		return
	}

	result := map[string]any{"entry": entry}

	if entry.Status == "applied" {
		deductions, _ := stockRepo.GetSaleEntryDeductions(r.Context(), id)
		result["deductions"] = deductions
	}

	writeJSON(w, http.StatusOK, result)
}

type addSaleItemRequest struct {
	MenuItemID string `json:"menu_item_id"`
	Quantity   int    `json:"quantity"`
}

func (h *StockAPIHandler) addSaleItem(w http.ResponseWriter, r *http.Request) {
	var req addSaleItemRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	saleEntryID, _ := uuid.Parse(r.PathValue("id"))
	menuItemID, err := uuid.Parse(req.MenuItemID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid menu_item_id")
		return
	}

	if req.Quantity <= 0 {
		writeError(w, http.StatusBadRequest, "quantity must be positive")
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	recipeRepo := repository.NewRecipeRepo(pool)

	mi, err := recipeRepo.GetRecipeByID(r.Context(), menuItemID)
	var price float64
	if err == nil {
		price = mi.SellingPrice
	}

	if err := stockRepo.AddSaleEntryItem(r.Context(), saleEntryID, menuItemID, req.Quantity, price); err != nil {
		slog.Error("api: add sale item", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to add item")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "item added"})
}

func (h *StockAPIHandler) removeSaleItem(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	itemID, err := uuid.Parse(r.PathValue("itemId"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid item id")
		return
	}

	if err := stockRepo.DeleteSaleEntryItem(r.Context(), itemID); err != nil {
		slog.Error("api: remove sale item", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to remove item")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "item removed"})
}

func (h *StockAPIHandler) applySale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	saleEntryID, _ := uuid.Parse(r.PathValue("id"))

	if err := stockRepo.ApplySaleEntry(r.Context(), saleEntryID, userID); err != nil {
		slog.Error("api: apply sale entry", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to apply: "+err.Error())
		return
	}

	entry, _ := stockRepo.GetSaleEntryByID(r.Context(), saleEntryID)

	// Audit log: apply sale entry
	if newJSON, err := json.Marshal(entry); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "update", "sale_entry", saleEntryID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, entry)
}

func (h *StockAPIHandler) deleteSale(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	id, _ := uuid.Parse(r.PathValue("id"))

	oldEntry, _ := stockRepo.GetSaleEntryByID(r.Context(), id)

	stockRepo.DeleteSaleEntry(r.Context(), id)

	// Audit log: delete sale entry
	if oldJSON, err := json.Marshal(oldEntry); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "delete", "sale_entry", id, oldJSON, nil, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "deleted"})
}

// Wastage

type createWastageRequest struct {
	IngredientID string  `json:"ingredient_id"`
	Quantity     float64 `json:"quantity"`
	WastageType  string  `json:"wastage_type"`
	WastageDate  string  `json:"wastage_date"`
	Notes        string  `json:"notes"`
}

func (h *StockAPIHandler) createWastage(w http.ResponseWriter, r *http.Request) {
	var req createWastageRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	ingredientID, err := uuid.Parse(req.IngredientID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid ingredient_id")
		return
	}

	if req.Quantity <= 0 {
		writeError(w, http.StatusBadRequest, "quantity must be positive")
		return
	}

	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	record, err := stockRepo.CreateWastageRecord(r.Context(), ingredientID, req.Quantity, req.WastageType, req.WastageDate, req.Notes, userID)
	if err != nil {
		slog.Error("api: create wastage record", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to record wastage")
		return
	}

	// Audit log: create wastage
	if newJSON, err := json.Marshal(record); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "create", "wastage", record.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, record)
}

func (h *StockAPIHandler) listWastage(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	q := r.URL.Query()
	records, err := stockRepo.ListWastageRecords(r.Context(), q.Get("ingredient"), q.Get("type"))
	if err != nil {
		slog.Error("api: list wastage records", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list wastage")
		return
	}

	writeJSON(w, http.StatusOK, records)
}

// Stock Movements

func (h *StockAPIHandler) listMovements(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	stockRepo := repository.NewStockRepo(pool)

	q := r.URL.Query()
	limit := 100
	if l := q.Get("limit"); l != "" {
		if v, err := strconv.Atoi(l); err == nil && v > 0 {
			limit = v
		}
	}

	movements, err := stockRepo.ListStockMovements(r.Context(), q.Get("ingredient"), q.Get("type"), limit)
	if err != nil {
		slog.Error("api: list stock movements", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list stock movements")
		return
	}

	writeJSON(w, http.StatusOK, movements)
}
