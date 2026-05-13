package apihandler

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"searlo-cafe/internal/ai"
	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/storage"
	"searlo-cafe/internal/units"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type BillAPIHandler struct {
	scanner   ai.BillScanner
	uploadDir string
	store     *storage.ImageStore
}

func NewBillAPIHandler(scanner ai.BillScanner, uploadDir string, store *storage.ImageStore) *BillAPIHandler {
	return &BillAPIHandler{scanner: scanner, uploadDir: uploadDir, store: store}
}

func (h *BillAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/bills", wrap(h.list, "bills", "read"))
	mux.Handle("POST /api/v1/bills/upload", wrap(h.upload, "bills", "create"))
	mux.Handle("POST /api/v1/bills/manual", wrap(h.manual, "bills", "create"))
	mux.Handle("GET /api/v1/bills/{id}", wrap(h.show, "bills", "read"))
	mux.Handle("PUT /api/v1/bills/{id}", wrap(h.update, "bills", "update"))
	mux.Handle("DELETE /api/v1/bills/{id}", wrap(h.deleteBill, "bills", "delete"))
	mux.Handle("POST /api/v1/bills/{id}/items", wrap(h.addItem, "bills", "update"))
	mux.Handle("DELETE /api/v1/bills/{id}/items/{itemId}", wrap(h.deleteItem, "bills", "update"))
	mux.Handle("POST /api/v1/bills/{id}/map/{itemId}", wrap(h.mapItem, "bills", "update"))
	mux.Handle("POST /api/v1/bills/{id}/create-ingredient/{itemId}", wrap(h.createIngredientFromItem, "bills", "update"))
	mux.Handle("POST /api/v1/bills/{id}/create-vendor", wrap(h.createVendorFromBill, "vendors", "create"))
	mux.Handle("POST /api/v1/bills/{id}/apply", wrap(h.applyBill, "bills", "update"))
}

func (h *BillAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewBillRepo(pool)

	q := r.URL.Query()
	bills, err := repo.List(r.Context(), q.Get("search"), q.Get("status"), q.Get("date_from"), q.Get("date_to"), q.Get("sort"))
	if err != nil {
		slog.Error("api: list bills", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list bills")
		return
	}

	writeJSON(w, http.StatusOK, bills)
}

func (h *BillAPIHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	bill, err := billRepo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "bill not found")
		return
	}

	items, _ := billRepo.GetBillItems(r.Context(), id)
	bill.Items = items

	writeJSON(w, http.StatusOK, bill)
}

func (h *BillAPIHandler) upload(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "file too large")
		return
	}

	file, header, err := r.FormFile("bill_image")
	if err != nil {
		writeError(w, http.StatusBadRequest, "no file uploaded")
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp" {
		writeError(w, http.StatusBadRequest, "only JPG, PNG, and WebP images are supported")
		return
	}

	imageData, err := io.ReadAll(file)
	if err != nil {
		slog.Error("read upload", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to read file")
		return
	}

	orgDB := middleware.GetOrgDB(r.Context())
	var imagePath string
	if h.store != nil {
		objectKey, err := h.store.Upload(r.Context(), orgDB, "bills", bytes.NewReader(imageData), header.Filename)
		if err != nil {
			slog.Error("upload bill image to spaces", "error", err)
			writeError(w, http.StatusInternalServerError, "failed to upload image")
			return
		}
		imagePath = objectKey
	} else {
		writeError(w, http.StatusInternalServerError, "image storage not configured")
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	userID := middleware.GetUserID(r.Context())

	var vendorID *uuid.UUID
	if vid := r.FormValue("vendor_id"); vid != "" {
		if parsed, err := uuid.Parse(vid); err == nil {
			vendorID = &parsed
		}
	}

	bill, err := billRepo.Create(r.Context(), vendorID, r.FormValue("bill_number"), nil, &imagePath, "scan", userID)
	if err != nil {
		slog.Error("create bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create bill")
		return
	}

	mimeType := "image/jpeg"
	if ext == ".png" {
		mimeType = "image/png"
	} else if ext == ".webp" {
		mimeType = "image/webp"
	}

	extraction, err := h.scanner.ExtractBillData(r.Context(), imageData, mimeType)
	if err != nil {
		slog.Error("ai extraction failed", "error", err)
		billRepo.UpdateStatus(r.Context(), bill.ID, "failed")
	} else {
		// Auto-link vendor if caller didn't pick one and AI detected a match.
		if vendorID == nil && extraction.VendorName != "" {
			vendorRepo := repository.NewVendorRepo(pool)
			allVendors, _ := vendorRepo.List(r.Context(), "", "")
			if matched := apiFindMatchingVendor(extraction.VendorName, allVendors); matched != nil {
				if err := billRepo.Update(r.Context(), bill.ID, &matched.ID, bill.BillNumber, bill.BillDate, bill.TotalAmount, bill.Notes, bill.ImagePath); err != nil {
					slog.Error("auto-link vendor", "error", err)
				} else {
					bill.VendorID = &matched.ID
					bill.Vendor = &model.Vendor{ID: matched.ID, Name: matched.Name}
				}
			}
		}

		raw, _ := json.Marshal(extraction)
		billRepo.UpdateAIResponse(r.Context(), bill.ID, raw, "processing")

		ingredientRepo := repository.NewIngredientRepo(pool)
		ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
		allUnits, _ := ingredientRepo.ListUnits(r.Context())

		for _, aiItem := range extraction.Items {
			item := model.VendorBillItem{
				BillID:        bill.ID,
				RawItemName:   aiItem.Name,
				RawQuantity:   aiItem.Quantity,
				RawUnit:       aiItem.Unit,
				RawUnitPrice:  aiItem.UnitPrice,
				RawTotalPrice: aiItem.Total,
				MappingStatus: "unmapped",
			}

			if u := units.Resolve(aiItem.Unit, allUnits); u != nil {
				item.BillUnitID = &u.ID
			}

			if matched := apiFindMatchingIngredient(aiItem.Name, ingredients); matched != nil {
				item.IngredientID = &matched.ID
				item.MappedQuantity = aiItem.Quantity
				item.MappingStatus = "auto_mapped"
				now := time.Now()
				item.MappedAt = &now
			}

			billRepo.CreateItem(r.Context(), item)
		}

		updateBillStatus(r.Context(), billRepo, bill.ID)
	}

	// Reload bill with items.
	bill, _ = billRepo.GetByID(r.Context(), bill.ID)
	items, _ := billRepo.GetBillItems(r.Context(), bill.ID)
	bill.Items = items

	// Audit log: create bill (upload)
	if newJSON, err := json.Marshal(bill); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "create", "bill", bill.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, bill)
}

type manualBillRequest struct {
	VendorID   string `json:"vendor_id"`
	BillNumber string `json:"bill_number"`
	BillDate   string `json:"bill_date"`
	Items      []struct {
		Name      string   `json:"name"`
		Quantity  *float64 `json:"quantity"`
		Unit      string   `json:"unit"`
		UnitPrice *float64 `json:"unit_price"`
		Total     *float64 `json:"total"`
	} `json:"items"`
}

func (h *BillAPIHandler) manual(w http.ResponseWriter, r *http.Request) {
	var req manualBillRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)
	userID := middleware.GetUserID(r.Context())

	var vendorID *uuid.UUID
	if req.VendorID != "" {
		if parsed, err := uuid.Parse(req.VendorID); err == nil {
			vendorID = &parsed
		}
	}

	var billDate *time.Time
	if req.BillDate != "" {
		if t, err := time.Parse("2006-01-02", req.BillDate); err == nil {
			billDate = &t
		}
	}

	bill, err := billRepo.Create(r.Context(), vendorID, req.BillNumber, billDate, nil, "manual", userID)
	if err != nil {
		slog.Error("api: create manual bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create bill")
		return
	}

	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	allUnits, _ := ingredientRepo.ListUnits(r.Context())

	for _, ri := range req.Items {
		name := strings.TrimSpace(ri.Name)
		if name == "" {
			continue
		}

		item := model.VendorBillItem{
			BillID:        bill.ID,
			RawItemName:   name,
			RawQuantity:   ri.Quantity,
			RawUnit:       ri.Unit,
			RawUnitPrice:  ri.UnitPrice,
			RawTotalPrice: ri.Total,
			MappingStatus: "unmapped",
		}

		if u := units.Resolve(ri.Unit, allUnits); u != nil {
			item.BillUnitID = &u.ID
		}

		if matched := apiFindMatchingIngredient(name, ingredients); matched != nil {
			item.IngredientID = &matched.ID
			item.MappedQuantity = ri.Quantity
			item.MappingStatus = "auto_mapped"
			now := time.Now()
			item.MappedAt = &now
		}

		billRepo.CreateItem(r.Context(), item)
	}

	updateBillStatus(r.Context(), billRepo, bill.ID)

	bill, _ = billRepo.GetByID(r.Context(), bill.ID)
	items, _ := billRepo.GetBillItems(r.Context(), bill.ID)
	bill.Items = items

	// Audit log: create bill (manual)
	if newJSON, err := json.Marshal(bill); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "create", "bill", bill.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, bill)
}

type updateBillRequest struct {
	VendorID    string   `json:"vendor_id"`
	BillNumber  string   `json:"bill_number"`
	BillDate    string   `json:"bill_date"`
	TotalAmount *float64 `json:"total_amount"`
	Notes       string   `json:"notes"`
}

func (h *BillAPIHandler) update(w http.ResponseWriter, r *http.Request) {
	var req updateBillRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	oldBill, err := billRepo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "bill not found")
		return
	}

	var vendorID *uuid.UUID
	if req.VendorID != "" {
		if parsed, err := uuid.Parse(req.VendorID); err == nil {
			vendorID = &parsed
		}
	}

	var billDate *time.Time
	if req.BillDate != "" {
		if t, err := time.Parse("2006-01-02", req.BillDate); err == nil {
			billDate = &t
		}
	}

	if err := billRepo.Update(r.Context(), id, vendorID, req.BillNumber, billDate, req.TotalAmount, req.Notes, oldBill.ImagePath); err != nil {
		slog.Error("api: update bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to update bill")
		return
	}

	bill, _ := billRepo.GetByID(r.Context(), id)
	items, _ := billRepo.GetBillItems(r.Context(), id)
	bill.Items = items

	if newJSON, err := json.Marshal(bill); err == nil {
		oldJSON, _ := json.Marshal(oldBill)
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "update", "bill", id, oldJSON, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, bill)
}

func (h *BillAPIHandler) deleteBill(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	oldBill, err := billRepo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "bill not found")
		return
	}

	if oldBill.ImagePath != "" && h.store != nil {
		h.store.Delete(r.Context(), oldBill.ImagePath)
	}

	if err := billRepo.Delete(r.Context(), id); err != nil {
		slog.Error("api: delete bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to delete bill")
		return
	}

	if oldJSON, err := json.Marshal(oldBill); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "delete", "bill", id, oldJSON, nil, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "bill deleted"})
}

type addBillItemRequest struct {
	Name      string   `json:"name"`
	Quantity  *float64 `json:"quantity"`
	Unit      string   `json:"unit"`
	UnitPrice *float64 `json:"unit_price"`
	Total     *float64 `json:"total"`
}

func (h *BillAPIHandler) addItem(w http.ResponseWriter, r *http.Request) {
	var req addBillItemRequest
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
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	allUnits, _ := ingredientRepo.ListUnits(r.Context())
	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")

	item := model.VendorBillItem{
		BillID:        billID,
		RawItemName:   req.Name,
		RawQuantity:   req.Quantity,
		RawUnit:       req.Unit,
		RawUnitPrice:  req.UnitPrice,
		RawTotalPrice: req.Total,
		MappingStatus: "unmapped",
	}

	if u := units.Resolve(req.Unit, allUnits); u != nil {
		item.BillUnitID = &u.ID
	}

	if matched := apiFindMatchingIngredient(req.Name, ingredients); matched != nil {
		item.IngredientID = &matched.ID
		item.MappedQuantity = req.Quantity
		item.MappingStatus = "auto_mapped"
		now := time.Now()
		item.MappedAt = &now
	}

	if err := billRepo.CreateItem(r.Context(), item); err != nil {
		slog.Error("api: add bill item", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to add item")
		return
	}

	updateBillStatus(r.Context(), billRepo, billID)

	bill, _ := billRepo.GetByID(r.Context(), billID)
	items, _ := billRepo.GetBillItems(r.Context(), billID)
	bill.Items = items
	writeJSON(w, http.StatusCreated, bill)
}

func (h *BillAPIHandler) deleteItem(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid bill id")
		return
	}

	itemID, err := uuid.Parse(r.PathValue("itemId"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid item id")
		return
	}

	if err := billRepo.DeleteItem(r.Context(), itemID); err != nil {
		slog.Error("api: delete bill item", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to delete item")
		return
	}

	updateBillStatus(r.Context(), billRepo, billID)

	writeJSON(w, http.StatusOK, map[string]string{"message": "item deleted"})
}

type mapItemRequest struct {
	IngredientID   string  `json:"ingredient_id"`
	MappedQuantity float64 `json:"mapped_quantity"`
	BillUnitID     string  `json:"bill_unit_id"`
}

func (h *BillAPIHandler) mapItem(w http.ResponseWriter, r *http.Request) {
	var req mapItemRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, _ := uuid.Parse(r.PathValue("id"))
	itemID, _ := uuid.Parse(r.PathValue("itemId"))
	ingredientID, err := uuid.Parse(req.IngredientID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid ingredient_id")
		return
	}

	qty := req.MappedQuantity
	var billUnitID *uuid.UUID
	var mappedUnitPrice *float64

	if req.BillUnitID != "" {
		if parsed, err := uuid.Parse(req.BillUnitID); err == nil {
			billUnitID = &parsed
			billUnit, err := ingredientRepo.GetUnitByID(r.Context(), parsed)
			if err == nil {
				ing, err := ingredientRepo.GetByID(r.Context(), ingredientID)
				if err == nil && ing.Unit != nil {
					convertedQty, err := units.ConvertQuantity(qty, billUnit, ing.Unit)
					if err != nil {
						writeError(w, http.StatusBadRequest, err.Error())
						return
					}
					qty = convertedQty
					items, _ := billRepo.GetBillItems(r.Context(), billID)
					for _, it := range items {
						if it.ID == itemID && it.RawUnitPrice != nil {
							converted, err := units.ConvertPrice(*it.RawUnitPrice, billUnit, ing.Unit)
							if err != nil {
								writeError(w, http.StatusBadRequest, err.Error())
								return
							}
							mappedUnitPrice = &converted
							break
						}
					}
				}
			}
		}
	}

	if err := billRepo.MapItem(r.Context(), itemID, ingredientID, billUnitID, qty, mappedUnitPrice); err != nil {
		slog.Error("api: map item", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to map item")
		return
	}

	// Audit log: map bill item
	if newJSON, err := json.Marshal(map[string]any{"bill_id": billID, "item_id": itemID, "ingredient_id": ingredientID, "quantity": qty}); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "update", "bill", billID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "item mapped"})
}

type createIngredientFromItemRequest struct {
	Name        string  `json:"name"`
	CategoryID  string  `json:"category_id"`
	UnitID      string  `json:"unit_id"`
	Quantity    float64 `json:"quantity"`
	CostPerUnit float64 `json:"cost_per_unit"`
}

func (h *BillAPIHandler) createIngredientFromItem(w http.ResponseWriter, r *http.Request) {
	var req createIngredientFromItemRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeError(w, http.StatusBadRequest, "name is required")
		return
	}

	unitID, err := uuid.Parse(req.UnitID)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid unit_id")
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, _ := uuid.Parse(r.PathValue("id"))
	itemID, _ := uuid.Parse(r.PathValue("itemId"))

	var categoryID *uuid.UUID
	if req.CategoryID != "" {
		if parsed, err := uuid.Parse(req.CategoryID); err == nil {
			categoryID = &parsed
		}
	}

	qty := req.Quantity
	costPerUnit := req.CostPerUnit

	// The form's qty and cost live in the bill item's unit. Convert to the user's chosen storage unit.
	var billUnitID *uuid.UUID
	items, _ := billRepo.GetBillItems(r.Context(), billID)
	for _, it := range items {
		if it.ID == itemID {
			billUnitID = it.BillUnitID
			break
		}
	}
	if billUnitID != nil && *billUnitID != unitID {
		billUnit, err := ingredientRepo.GetUnitByID(r.Context(), *billUnitID)
		if err != nil {
			writeError(w, http.StatusBadRequest, "invalid bill unit")
			return
		}
		storeUnit, err := ingredientRepo.GetUnitByID(r.Context(), unitID)
		if err != nil {
			writeError(w, http.StatusBadRequest, "invalid unit_id")
			return
		}
		convQty, err := units.ConvertQuantity(qty, billUnit, storeUnit)
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		convCost, err := units.ConvertPrice(costPerUnit, billUnit, storeUnit)
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		qty = convQty
		costPerUnit = convCost
	}

	ing, err := ingredientRepo.Create(r.Context(), repository.CreateIngredientParams{
		Name:                 req.Name,
		UnitID:               unitID,
		CurrentStock:         qty,
		CurrentCostPerUnit:   costPerUnit,
		PriceAlertPercentage: 10.0,
		CategoryID:           categoryID,
	})
	if err != nil {
		slog.Error("api: create ingredient from bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create ingredient")
		return
	}

	billRepo.MapItem(r.Context(), itemID, ing.ID, billUnitID, qty, &costPerUnit)

	writeJSON(w, http.StatusCreated, ing)
}

// createVendorFromBill creates a vendor using the AI-extracted vendor details
// stored on the bill, then links the bill to that new vendor.
func (h *BillAPIHandler) createVendorFromBill(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	vendorRepo := repository.NewVendorRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	bill, err := billRepo.GetByID(r.Context(), billID)
	if err != nil {
		writeError(w, http.StatusNotFound, "bill not found")
		return
	}

	if bill.VendorID != nil {
		writeError(w, http.StatusConflict, "bill already has a vendor")
		return
	}

	var extraction model.AIBillExtraction
	if len(bill.AIRawResponse) > 0 {
		if err := json.Unmarshal(bill.AIRawResponse, &extraction); err != nil {
			slog.Error("api: decode ai_raw_response", "error", err, "bill_id", billID)
		}
	}

	name := strings.TrimSpace(extraction.VendorName)
	if name == "" {
		writeError(w, http.StatusBadRequest, "no vendor name detected on this bill")
		return
	}

	vendor, err := vendorRepo.Create(r.Context(), repository.CreateVendorParams{
		Name:    name,
		Phone:   strings.TrimSpace(extraction.VendorPhone),
		Address: strings.TrimSpace(extraction.VendorAddress),
	})
	if err != nil {
		slog.Error("api: create vendor from bill", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create vendor")
		return
	}

	if err := billRepo.Update(r.Context(), billID, &vendor.ID, bill.BillNumber, bill.BillDate, bill.TotalAmount, bill.Notes, bill.ImagePath); err != nil {
		slog.Error("api: link bill to new vendor", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to link vendor")
		return
	}

	auditRepo := repository.NewAuditRepo(pool)
	if vendorJSON, err := json.Marshal(vendor); err == nil {
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "create", "vendor", vendor.ID, nil, vendorJSON, middleware.GetIPAddress(r))
	}

	updated, _ := billRepo.GetByID(r.Context(), billID)
	items, _ := billRepo.GetBillItems(r.Context(), billID)
	if updated != nil {
		updated.Items = items
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"vendor": vendor,
		"bill":   updated,
	})
}

func (h *BillAPIHandler) applyBill(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	billID, _ := uuid.Parse(r.PathValue("id"))
	items, err := billRepo.GetBillItems(r.Context(), billID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get bill items")
		return
	}

	for _, item := range items {
		if item.IngredientID == nil || item.MappingStatus == "unmapped" || item.MappingStatus == "skipped" {
			continue
		}

		qty := float64(0)
		if item.MappedQuantity != nil {
			qty = *item.MappedQuantity
		}
		if qty > 0 {
			ingredientRepo.UpdateStock(r.Context(), *item.IngredientID, qty)
			stockRepo.RecordMovement(r.Context(), nil, *item.IngredientID, qty, "purchase", "vendor_bill", &billID, "", userID)
		}

		var unitPrice float64
		if item.MappedUnitPrice != nil && *item.MappedUnitPrice > 0 {
			unitPrice = *item.MappedUnitPrice
		} else if item.RawUnitPrice != nil && *item.RawUnitPrice > 0 {
			unitPrice = *item.RawUnitPrice
		}

		if unitPrice > 0 {
			ing, err := ingredientRepo.GetByID(r.Context(), *item.IngredientID)
			if err == nil && ing.CurrentCostPerUnit != unitPrice {
				oldPrice := ing.CurrentCostPerUnit
				ingredientRepo.RecordPriceChange(r.Context(), ing.ID, oldPrice, unitPrice, "bill_scan", &billID)
				ingredientRepo.UpdatePrice(r.Context(), ing.ID, unitPrice)

				recipeRepo := repository.NewRecipeRepo(pool)
				reason := fmt.Sprintf("%s price %.2f → %.2f", ing.Name, oldPrice, unitPrice)
				if err := recipeRepo.SnapshotRecipesUsingIngredient(r.Context(), ing.ID, reason); err != nil {
					slog.Error("api: snapshot recipes using ingredient", "error", err)
				}

				if oldPrice > 0 {
					changePct := ((unitPrice - oldPrice) / oldPrice) * 100
					if changePct > ing.PriceAlertPercentage {
						apiCreatePriceAlert(r.Context(), pool, ing, oldPrice, unitPrice, changePct)
					}
				}
			}
		}
	}

	billRepo.UpdateStatus(r.Context(), billID, "mapped")

	bill, _ := billRepo.GetByID(r.Context(), billID)
	items, _ = billRepo.GetBillItems(r.Context(), billID)
	bill.Items = items

	// Audit log: apply bill
	if newJSON, err := json.Marshal(bill); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), userID, middleware.GetUserName(r.Context()), "update", "bill", billID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, bill)
}

func apiFindMatchingIngredient(name string, ingredients []model.Ingredient) *model.Ingredient {
	name = strings.ToLower(strings.TrimSpace(name))
	for i, ing := range ingredients {
		if strings.ToLower(ing.Name) == name {
			return &ingredients[i]
		}
	}
	for i, ing := range ingredients {
		ingName := strings.ToLower(ing.Name)
		if strings.Contains(name, ingName) || strings.Contains(ingName, name) {
			return &ingredients[i]
		}
	}
	return nil
}

func apiFindMatchingVendor(name string, vendors []model.Vendor) *model.Vendor {
	n := strings.ToLower(strings.TrimSpace(name))
	if n == "" {
		return nil
	}
	for i, v := range vendors {
		if strings.ToLower(v.Name) == n {
			return &vendors[i]
		}
	}
	for i, v := range vendors {
		vn := strings.ToLower(v.Name)
		if vn == "" {
			continue
		}
		if strings.Contains(n, vn) || strings.Contains(vn, n) {
			return &vendors[i]
		}
	}
	return nil
}

func updateBillStatus(ctx context.Context, billRepo *repository.BillRepo, billID uuid.UUID) {
	items, _ := billRepo.GetBillItems(ctx, billID)
	allMapped := true
	anyMapped := false
	for _, it := range items {
		if it.MappingStatus == "unmapped" {
			allMapped = false
		} else {
			anyMapped = true
		}
	}
	status := "processing"
	if allMapped && len(items) > 0 {
		status = "mapped"
	} else if anyMapped {
		status = "partially_mapped"
	}
	billRepo.UpdateStatus(ctx, billID, status)
}

func apiCreatePriceAlert(ctx context.Context, pool *pgxpool.Pool, ing *model.Ingredient, oldPrice, newPrice, changePct float64) {
	details, _ := json.Marshal(map[string]any{
		"old_price":         oldPrice,
		"new_price":         newPrice,
		"change_percentage": changePct,
	})
	pool.Exec(ctx,
		`INSERT INTO alerts (alert_type, ingredient_id, message, details)
		 VALUES ('price_increase', $1, $2, $3)`,
		ing.ID,
		fmt.Sprintf("%s price increased by %.1f%% (from %.2f to %.2f)", ing.Name, changePct, oldPrice, newPrice),
		details,
	)
}

