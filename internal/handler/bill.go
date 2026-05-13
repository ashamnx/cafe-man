package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"strconv"

	"searlo-cafe/internal/ai"
	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/storage"
	"searlo-cafe/internal/units"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type BillHandler struct {
	render    *Renderer
	scanner   ai.BillScanner
	uploadDir string
	store     *storage.ImageStore
}

func NewBillHandler(render *Renderer, scanner ai.BillScanner, uploadDir string, store *storage.ImageStore) *BillHandler {
	return &BillHandler{render: render, scanner: scanner, uploadDir: uploadDir, store: store}
}

func (h *BillHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /bills", wrap(h.list, "bills", "read"))
	mux.Handle("GET /bills/upload", wrap(h.showUpload, "bills", "create"))
	mux.Handle("POST /bills/upload", wrap(h.handleUpload, "bills", "create"))
	mux.Handle("POST /bills/manual", wrap(h.handleManualEntry, "bills", "create"))
	mux.Handle("GET /bills/{id}", wrap(h.show, "bills", "read"))
	mux.Handle("GET /bills/{id}/edit", wrap(h.showEdit, "bills", "update"))
	mux.Handle("PUT /bills/{id}", wrap(h.update, "bills", "update"))
	mux.Handle("DELETE /bills/{id}", wrap(h.delete, "bills", "delete"))
	mux.Handle("POST /bills/{id}/items", wrap(h.addItem, "bills", "update"))
	mux.Handle("DELETE /bills/{id}/items/{itemId}", wrap(h.deleteItem, "bills", "update"))
	mux.Handle("POST /bills/{id}/map/{itemId}", wrap(h.mapItem, "bills", "update"))
	mux.Handle("POST /bills/{id}/create-ingredient/{itemId}", wrap(h.createIngredientFromItem, "bills", "update"))
	mux.Handle("POST /bills/{id}/create-vendor", wrap(h.createVendorFromBill, "vendors", "create"))
	mux.Handle("POST /bills/{id}/apply", wrap(h.applyBill, "bills", "update"))
}

func (h *BillHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewBillRepo(pool)

	q := r.URL.Query()
	search := q.Get("search")
	status := q.Get("status")
	dateFrom := q.Get("date_from")
	dateTo := q.Get("date_to")
	sortBy := q.Get("sort")

	bills, err := repo.List(r.Context(), search, status, dateFrom, dateTo, sortBy)
	if err != nil {
		slog.Error("list bills", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.HTML(w, r, "bills.html", map[string]any{
		"Bills": bills,
		"Filters": map[string]string{
			"search":    search,
			"status":    status,
			"date_from": dateFrom,
			"date_to":   dateTo,
			"sort":      sortBy,
		},
		"Title": "Vendor Bills",
	})
}

func (h *BillHandler) showUpload(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	vendorRepo := repository.NewVendorRepo(pool)
	vendors, _ := vendorRepo.List(r.Context(), "", "")
	ingredientRepo := repository.NewIngredientRepo(pool)
	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	unitList, _ := ingredientRepo.ListUnits(r.Context())

	h.render.HTML(w, r, "bill_upload.html", map[string]any{
		"Vendors":     vendors,
		"Ingredients": ingredients,
		"Units":       unitList,
		"Title":       "Add Vendor Bill",
	})
}

func (h *BillHandler) handleUpload(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil { // 10MB max
		http.Error(w, "File too large", http.StatusBadRequest)
		return
	}

	file, header, err := r.FormFile("bill_image")
	if err != nil {
		http.Error(w, "No file uploaded", http.StatusBadRequest)
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp" {
		http.Error(w, "Only JPG, PNG, and WebP images are supported", http.StatusBadRequest)
		return
	}

	imageData, err := io.ReadAll(file)
	if err != nil {
		slog.Error("read upload", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// Upload to Spaces if available, else fall back to local storage.
	var imagePath string
	orgDB := middleware.GetOrgDB(r.Context())
	if h.store != nil {
		objectKey, err := h.store.Upload(r.Context(), orgDB, "bills", bytes.NewReader(imageData), header.Filename)
		if err != nil {
			slog.Error("upload bill image to spaces", "error", err)
			http.Error(w, "Failed to upload image", http.StatusInternalServerError)
			return
		}
		imagePath = objectKey
	} else {
		localPath, err := saveBillImageLocal(h.uploadDir, orgDB, ext, imageData)
		if err != nil {
			slog.Error("save bill image locally", "error", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
		imagePath = localPath
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
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// Run AI extraction.
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
		// Auto-link vendor if user didn't pick one and AI detected a match.
		if vendorID == nil && extraction.VendorName != "" {
			vendorRepo := repository.NewVendorRepo(pool)
			allVendors, _ := vendorRepo.List(r.Context(), "", "")
			if matched := findMatchingVendor(extraction.VendorName, allVendors); matched != nil {
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

		// Create bill items from AI extraction.
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

			// Try auto-mapping by name similarity.
			if matched := findMatchingIngredient(aiItem.Name, ingredients); matched != nil {
				item.IngredientID = &matched.ID
				item.MappedQuantity = aiItem.Quantity
				item.MappingStatus = "auto_mapped"
				now := time.Now()
				item.MappedAt = &now
			}

			billRepo.CreateItem(r.Context(), item)
		}

		updateBillMappingStatus(r.Context(), billRepo, bill.ID)
	}

	logAudit(r.Context(), pool, r, "create", "bill", bill.ID, nil, marshalAudit(bill))

	http.Redirect(w, r, fmt.Sprintf("/bills/%s", bill.ID), http.StatusSeeOther)
}

func (h *BillHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	bill, err := billRepo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	items, _ := billRepo.GetBillItems(r.Context(), id)
	bill.Items = items

	ingredientRepo := repository.NewIngredientRepo(pool)
	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	unitList, _ := ingredientRepo.ListUnits(r.Context())
	categories, _ := ingredientRepo.ListCategories(r.Context())

	vendorRepo := repository.NewVendorRepo(pool)
	vendors, _ := vendorRepo.List(r.Context(), "", "")

	// Decode AI extraction (if any) so the template can show the auto-match
	// badge or the single-tap "Create vendor" banner.
	var extraction model.AIBillExtraction
	if len(bill.AIRawResponse) > 0 {
		if err := json.Unmarshal(bill.AIRawResponse, &extraction); err != nil {
			slog.Error("decode ai_raw_response", "error", err, "bill_id", id)
		}
	}

	vendorAutoMatched := bill.EntryType == "scan" &&
		bill.Vendor != nil &&
		extraction.VendorName != "" &&
		findMatchingVendor(extraction.VendorName, []model.Vendor{*bill.Vendor}) != nil

	h.render.HTML(w, r, "bill_detail.html", map[string]any{
		"Bill":                 bill,
		"Ingredients":          ingredients,
		"Units":                unitList,
		"IngredientCategories": categories,
		"Vendors":              vendors,
		"AIExtraction":         extraction,
		"VendorAutoMatched":    vendorAutoMatched,
		"Title":                "Bill " + bill.BillNumber,
	})
}

func (h *BillHandler) showEdit(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	bill, err := billRepo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	vendorRepo := repository.NewVendorRepo(pool)
	vendors, _ := vendorRepo.List(r.Context(), "", "")

	h.render.HTML(w, r, "bill_edit.html", map[string]any{
		"Bill":    bill,
		"Vendors": vendors,
		"Title":   "Edit Bill",
	})
}

func (h *BillHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	oldBill, _ := billRepo.GetByID(r.Context(), id)

	var vendorID *uuid.UUID
	if vid := r.FormValue("vendor_id"); vid != "" {
		if parsed, err := uuid.Parse(vid); err == nil {
			vendorID = &parsed
		}
	}

	var billDate *time.Time
	if d := r.FormValue("bill_date"); d != "" {
		if t, err := time.Parse("2006-01-02", d); err == nil {
			billDate = &t
		}
	}

	var totalAmount *float64
	if ta := r.FormValue("total_amount"); ta != "" {
		if v, err := strconv.ParseFloat(ta, 64); err == nil {
			totalAmount = &v
		}
	}

	notes := strings.TrimSpace(r.FormValue("notes"))
	imagePath := r.FormValue("existing_image_path")

	// Handle optional new image upload.
	if file, header, err := r.FormFile("bill_image"); err == nil {
		defer file.Close()
		orgDB := middleware.GetOrgDB(r.Context())

		if h.store != nil {
			// Delete old image if replacing.
			if imagePath != "" {
				h.store.Delete(r.Context(), imagePath)
			}
			objectKey, err := h.store.Upload(r.Context(), orgDB, "bills", file, header.Filename)
			if err == nil {
				imagePath = objectKey
			} else {
				slog.Error("upload bill image", "error", err)
			}
		}
	}

	if err := billRepo.Update(r.Context(), id, vendorID, r.FormValue("bill_number"), billDate, totalAmount, notes, imagePath); err != nil {
		slog.Error("update bill", "error", err)
		http.Error(w, "Failed to update", http.StatusInternalServerError)
		return
	}

	newBill, _ := billRepo.GetByID(r.Context(), id)
	logAudit(r.Context(), pool, r, "update", "bill", id, marshalAudit(oldBill), marshalAudit(newBill))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+id.String(), http.StatusSeeOther)
}

func (h *BillHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	oldBill, _ := billRepo.GetByID(r.Context(), id)

	// Delete image from storage.
	if oldBill != nil && oldBill.ImagePath != "" && h.store != nil {
		h.store.Delete(r.Context(), oldBill.ImagePath)
	}

	if err := billRepo.Delete(r.Context(), id); err != nil {
		slog.Error("delete bill", "error", err)
		http.Error(w, "Failed to delete", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "delete", "bill", id, marshalAudit(oldBill), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills", http.StatusSeeOther)
}

func (h *BillHandler) addItem(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	name := strings.TrimSpace(r.FormValue("item_name"))
	if name == "" {
		http.Error(w, "Item name is required", http.StatusBadRequest)
		return
	}

	qty := optionalFloat(r.FormValue("item_qty"))
	unitPrice := optionalFloat(r.FormValue("item_unit_price"))
	total := optionalFloat(r.FormValue("item_total"))
	rawUnit := r.FormValue("item_unit")

	allUnits, _ := ingredientRepo.ListUnits(r.Context())
	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")

	item := model.VendorBillItem{
		BillID:        billID,
		RawItemName:   name,
		RawQuantity:   qty,
		RawUnit:       rawUnit,
		RawUnitPrice:  unitPrice,
		RawTotalPrice: total,
		MappingStatus: "unmapped",
	}

	if u := units.Resolve(rawUnit, allUnits); u != nil {
		item.BillUnitID = &u.ID
	}

	if matched := findMatchingIngredient(name, ingredients); matched != nil {
		item.IngredientID = &matched.ID
		item.MappedQuantity = qty
		item.MappingStatus = "auto_mapped"
		now := time.Now()
		item.MappedAt = &now
	}

	if err := billRepo.CreateItem(r.Context(), item); err != nil {
		slog.Error("add bill item", "error", err)
		http.Error(w, "Failed to add item", http.StatusInternalServerError)
		return
	}

	updateBillMappingStatus(r.Context(), billRepo, billID)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

func (h *BillHandler) deleteItem(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	itemID, err := uuid.Parse(r.PathValue("itemId"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	if err := billRepo.DeleteItem(r.Context(), itemID); err != nil {
		slog.Error("delete bill item", "error", err)
		http.Error(w, "Failed to delete item", http.StatusInternalServerError)
		return
	}

	updateBillMappingStatus(r.Context(), billRepo, billID)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

func (h *BillHandler) mapItem(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, _ := uuid.Parse(r.PathValue("id"))
	itemID, _ := uuid.Parse(r.PathValue("itemId"))
	ingredientID, _ := uuid.Parse(r.FormValue("ingredient_id"))
	qty := parseFloat(r.FormValue("mapped_quantity"))

	var billUnitID *uuid.UUID
	if buid := r.FormValue("bill_unit_id"); buid != "" {
		if parsed, err := uuid.Parse(buid); err == nil {
			billUnitID = &parsed
		}
	}

	// Convert quantity and price if bill unit differs from ingredient unit.
	var mappedUnitPrice *float64
	if billUnitID != nil {
		billUnit, err := ingredientRepo.GetUnitByID(r.Context(), *billUnitID)
		if err == nil {
			ing, err := ingredientRepo.GetByID(r.Context(), ingredientID)
			if err == nil && ing.Unit != nil {
				convertedQty, err := units.ConvertQuantity(qty, billUnit, ing.Unit)
				if err != nil {
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}
				qty = convertedQty

				items, _ := billRepo.GetBillItems(r.Context(), billID)
				for _, it := range items {
					if it.ID == itemID && it.RawUnitPrice != nil {
						converted, err := units.ConvertPrice(*it.RawUnitPrice, billUnit, ing.Unit)
						if err != nil {
							http.Error(w, err.Error(), http.StatusBadRequest)
							return
						}
						mappedUnitPrice = &converted
						break
					}
				}
			}
		}
	}

	oldBill, _ := billRepo.GetByID(r.Context(), billID)

	if err := billRepo.MapItem(r.Context(), itemID, ingredientID, billUnitID, qty, mappedUnitPrice); err != nil {
		slog.Error("map item", "error", err)
		http.Error(w, "Failed to map", http.StatusInternalServerError)
		return
	}

	newBill, _ := billRepo.GetByID(r.Context(), billID)
	logAudit(r.Context(), pool, r, "update", "bill", billID, marshalAudit(oldBill), marshalAudit(newBill))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

// applyBill applies all mapped items: updates stock and price for each ingredient.
func (h *BillHandler) applyBill(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)
	stockRepo := repository.NewStockRepo(pool)
	userID := middleware.GetUserID(r.Context())

	billID, _ := uuid.Parse(r.PathValue("id"))
	oldBill, _ := billRepo.GetByID(r.Context(), billID)
	items, err := billRepo.GetBillItems(r.Context(), billID)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	for _, item := range items {
		if item.IngredientID == nil || item.MappingStatus == "unmapped" || item.MappingStatus == "skipped" {
			continue
		}

		// Update stock.
		qty := float64(0)
		if item.MappedQuantity != nil {
			qty = *item.MappedQuantity
		}
		if qty > 0 {
			ingredientRepo.UpdateStock(r.Context(), *item.IngredientID, qty)
			stockRepo.RecordMovement(r.Context(), nil, *item.IngredientID, qty, "purchase", "vendor_bill", &billID, "", userID)
		}

		// Update price if we have unit price data.
		// Prefer mapped_unit_price (converted to ingredient's unit) over raw_unit_price.
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
					slog.Error("snapshot recipes using ingredient", "error", err)
				}

				// Check price alert threshold.
				if oldPrice > 0 {
					changePct := ((unitPrice - oldPrice) / oldPrice) * 100
					if changePct > ing.PriceAlertPercentage {
						createPriceAlert(r.Context(), pool, ing, oldPrice, unitPrice, changePct)
					}
				}
			}
		}
	}

	billRepo.UpdateStatus(r.Context(), billID, "mapped")

	newBill, _ := billRepo.GetByID(r.Context(), billID)
	logAudit(r.Context(), pool, r, "update", "bill", billID, marshalAudit(oldBill), marshalAudit(newBill))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

// createIngredientFromItem creates a new ingredient from a bill line item and maps it.
func (h *BillHandler) createIngredientFromItem(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)

	billID, _ := uuid.Parse(r.PathValue("id"))
	itemID, _ := uuid.Parse(r.PathValue("itemId"))

	unitID, err := uuid.Parse(r.FormValue("unit_id"))
	if err != nil {
		http.Error(w, "Unit is required", http.StatusBadRequest)
		return
	}

	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}

	var categoryID *uuid.UUID
	if cid := r.FormValue("category_id"); cid != "" {
		if parsed, err := uuid.Parse(cid); err == nil {
			categoryID = &parsed
		}
	}
	qty := parseFloat(r.FormValue("quantity"))
	costPerUnit := parseFloat(r.FormValue("cost_per_unit"))

	// The form's qty and cost are pre-filled from the raw bill values, so they
	// live in the bill item's unit. Convert to the user's chosen storage unit.
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
			http.Error(w, "Invalid bill unit", http.StatusBadRequest)
			return
		}
		storeUnit, err := ingredientRepo.GetUnitByID(r.Context(), unitID)
		if err != nil {
			http.Error(w, "Invalid unit", http.StatusBadRequest)
			return
		}
		convQty, err := units.ConvertQuantity(qty, billUnit, storeUnit)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		convCost, err := units.ConvertPrice(costPerUnit, billUnit, storeUnit)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		qty = convQty
		costPerUnit = convCost
	}

	params := repository.CreateIngredientParams{
		Name:                 name,
		UnitID:               unitID,
		CurrentStock:         qty,
		CurrentCostPerUnit:   costPerUnit,
		PriceAlertPercentage: 10.0,
		CategoryID:           categoryID,
	}

	ing, err := ingredientRepo.Create(r.Context(), params)
	if err != nil {
		slog.Error("create ingredient from bill", "error", err)
		http.Error(w, "Failed to create ingredient", http.StatusInternalServerError)
		return
	}

	if err := billRepo.MapItem(r.Context(), itemID, ing.ID, billUnitID, qty, &costPerUnit); err != nil {
		slog.Error("map item to new ingredient", "error", err)
	}

	slog.Info("created ingredient from bill item", "ingredient", ing.Name, "id", ing.ID)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

// createVendorFromBill creates a vendor using the AI-extracted vendor details
// stored on the bill, then links the bill to that new vendor.
func (h *BillHandler) createVendorFromBill(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	vendorRepo := repository.NewVendorRepo(pool)

	billID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	bill, err := billRepo.GetByID(r.Context(), billID)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	if bill.VendorID != nil {
		http.Error(w, "Bill already has a vendor", http.StatusConflict)
		return
	}

	var extraction model.AIBillExtraction
	if len(bill.AIRawResponse) > 0 {
		if err := json.Unmarshal(bill.AIRawResponse, &extraction); err != nil {
			slog.Error("decode ai_raw_response", "error", err, "bill_id", billID)
		}
	}

	name := strings.TrimSpace(extraction.VendorName)
	if name == "" {
		http.Error(w, "No vendor name detected on this bill", http.StatusBadRequest)
		return
	}

	vendor, err := vendorRepo.Create(r.Context(), repository.CreateVendorParams{
		Name:    name,
		Phone:   strings.TrimSpace(extraction.VendorPhone),
		Address: strings.TrimSpace(extraction.VendorAddress),
	})
	if err != nil {
		slog.Error("create vendor from bill", "error", err)
		http.Error(w, "Failed to create vendor", http.StatusInternalServerError)
		return
	}

	oldBill := *bill
	if err := billRepo.Update(r.Context(), billID, &vendor.ID, bill.BillNumber, bill.BillDate, bill.TotalAmount, bill.Notes, bill.ImagePath); err != nil {
		slog.Error("link bill to new vendor", "error", err)
		http.Error(w, "Failed to link vendor", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "create", "vendor", vendor.ID, nil, marshalAudit(vendor))
	newBill, _ := billRepo.GetByID(r.Context(), billID)
	logAudit(r.Context(), pool, r, "update", "bill", billID, marshalAudit(&oldBill), marshalAudit(newBill))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/bills/"+billID.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/bills/"+billID.String(), http.StatusSeeOther)
}

func (h *BillHandler) handleManualEntry(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	billRepo := repository.NewBillRepo(pool)
	ingredientRepo := repository.NewIngredientRepo(pool)
	userID := middleware.GetUserID(r.Context())

	var vendorID *uuid.UUID
	if vid := r.FormValue("vendor_id"); vid != "" {
		if parsed, err := uuid.Parse(vid); err == nil {
			vendorID = &parsed
		}
	}

	var billDate *time.Time
	if d := r.FormValue("bill_date"); d != "" {
		if t, err := time.Parse("2006-01-02", d); err == nil {
			billDate = &t
		}
	}

	// Handle optional image upload.
	var imagePath *string
	if file, header, err := r.FormFile("bill_image"); err == nil {
		defer file.Close()
		orgDB := middleware.GetOrgDB(r.Context())

		if h.store != nil {
			objectKey, err := h.store.Upload(r.Context(), orgDB, "bills", file, header.Filename)
			if err == nil {
				imagePath = &objectKey
			} else {
				slog.Error("upload bill image", "error", err)
			}
		} else {
			ext := strings.ToLower(filepath.Ext(header.Filename))
			imageData, err := io.ReadAll(file)
			if err == nil {
				localPath, err := saveBillImageLocal(h.uploadDir, orgDB, ext, imageData)
				if err == nil {
					imagePath = &localPath
				}
			}
		}
	}

	entryType := "manual"
	bill, err := billRepo.Create(r.Context(), vendorID, r.FormValue("bill_number"), billDate, imagePath, entryType, userID)
	if err != nil {
		slog.Error("create manual bill", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// Parse line items from parallel form arrays.
	itemNames := r.Form["item_name"]
	itemQtys := r.Form["item_qty"]
	itemUnits := r.Form["item_unit"]
	itemPrices := r.Form["item_unit_price"]
	itemTotals := r.Form["item_total"]

	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	allUnits, _ := ingredientRepo.ListUnits(r.Context())

	for i, name := range itemNames {
		name = strings.TrimSpace(name)
		if name == "" {
			continue
		}

		qty := optionalFloat(safeIndex(itemQtys, i))
		unitPrice := optionalFloat(safeIndex(itemPrices, i))
		total := optionalFloat(safeIndex(itemTotals, i))
		rawUnit := safeIndex(itemUnits, i)

		item := model.VendorBillItem{
			BillID:        bill.ID,
			RawItemName:   name,
			RawQuantity:   qty,
			RawUnit:       rawUnit,
			RawUnitPrice:  unitPrice,
			RawTotalPrice: total,
			MappingStatus: "unmapped",
		}

		if u := units.Resolve(rawUnit, allUnits); u != nil {
			item.BillUnitID = &u.ID
		}

		if matched := findMatchingIngredient(name, ingredients); matched != nil {
			item.IngredientID = &matched.ID
			item.MappedQuantity = qty
			item.MappingStatus = "auto_mapped"
			now := time.Now()
			item.MappedAt = &now
		}

		billRepo.CreateItem(r.Context(), item)
	}

	updateBillMappingStatus(r.Context(), billRepo, bill.ID)

	logAudit(r.Context(), pool, r, "create", "bill", bill.ID, nil, marshalAudit(bill))

	http.Redirect(w, r, fmt.Sprintf("/bills/%s", bill.ID), http.StatusSeeOther)
}

// updateBillMappingStatus recalculates and updates bill status based on item mapping.
func updateBillMappingStatus(ctx context.Context, billRepo *repository.BillRepo, billID uuid.UUID) {
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

func saveBillImageLocal(uploadDir, orgDB, ext string, imageData []byte) (string, error) {
	dir := filepath.Join(uploadDir, orgDB, "bills")
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", err
	}
	filename := uuid.New().String() + ext
	savePath := filepath.Join(dir, filename)
	if err := os.WriteFile(savePath, imageData, 0644); err != nil {
		return "", err
	}
	return savePath, nil
}

func safeIndex(slice []string, i int) string {
	if i < len(slice) {
		return slice[i]
	}
	return ""
}

func optionalFloat(s string) *float64 {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return nil
	}
	return &v
}

func findMatchingIngredient(name string, ingredients []model.Ingredient) *model.Ingredient {
	name = strings.ToLower(strings.TrimSpace(name))
	for i, ing := range ingredients {
		if strings.ToLower(ing.Name) == name {
			return &ingredients[i]
		}
	}
	// Fuzzy: check if ingredient name is contained in the raw name or vice versa.
	for i, ing := range ingredients {
		ingName := strings.ToLower(ing.Name)
		if strings.Contains(name, ingName) || strings.Contains(ingName, name) {
			return &ingredients[i]
		}
	}
	return nil
}

func findMatchingVendor(name string, vendors []model.Vendor) *model.Vendor {
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

func createPriceAlert(ctx context.Context, pool *pgxpool.Pool, ing *model.Ingredient, oldPrice, newPrice, changePct float64) {
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
