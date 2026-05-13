package apihandler

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
)

type VendorAPIHandler struct{}

func NewVendorAPIHandler() *VendorAPIHandler {
	return &VendorAPIHandler{}
}

func (h *VendorAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/vendors", wrap(h.list, "vendors", "read"))
	mux.Handle("POST /api/v1/vendors", wrap(h.create, "vendors", "create"))
	mux.Handle("GET /api/v1/vendors/{id}", wrap(h.show, "vendors", "read"))
	mux.Handle("PUT /api/v1/vendors/{id}", wrap(h.update, "vendors", "update"))
	mux.Handle("DELETE /api/v1/vendors/{id}", wrap(h.delete, "vendors", "delete"))
}

func (h *VendorAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	q := r.URL.Query()
	vendors, err := repo.List(r.Context(), q.Get("search"), q.Get("sort"))
	if err != nil {
		slog.Error("api: list vendors", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list vendors")
		return
	}

	writeJSON(w, http.StatusOK, vendors)
}

func (h *VendorAPIHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	vendor, err := repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusNotFound, "vendor not found")
		return
	}

	writeJSON(w, http.StatusOK, vendor)
}

type createVendorRequest struct {
	Name        string `json:"name"`
	ContactName string `json:"contact_name"`
	Phone       string `json:"phone"`
	Email       string `json:"email"`
	Address     string `json:"address"`
	Notes       string `json:"notes"`
}

func (h *VendorAPIHandler) create(w http.ResponseWriter, r *http.Request) {
	var req createVendorRequest
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
	repo := repository.NewVendorRepo(pool)

	vendor, err := repo.Create(r.Context(), repository.CreateVendorParams{
		Name:        req.Name,
		ContactName: strings.TrimSpace(req.ContactName),
		Phone:       strings.TrimSpace(req.Phone),
		Email:       strings.TrimSpace(req.Email),
		Address:     strings.TrimSpace(req.Address),
		Notes:       strings.TrimSpace(req.Notes),
	})
	if err != nil {
		slog.Error("api: create vendor", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to create vendor")
		return
	}

	// Audit log: create vendor
	if newJSON, err := json.Marshal(vendor); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "create", "vendor", vendor.ID, nil, newJSON, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusCreated, vendor)
}

func (h *VendorAPIHandler) update(w http.ResponseWriter, r *http.Request) {
	var req createVendorRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	oldVendor, _ := repo.GetByID(r.Context(), id)

	if err := repo.Update(r.Context(), id, repository.CreateVendorParams{
		Name:        strings.TrimSpace(req.Name),
		ContactName: strings.TrimSpace(req.ContactName),
		Phone:       strings.TrimSpace(req.Phone),
		Email:       strings.TrimSpace(req.Email),
		Address:     strings.TrimSpace(req.Address),
		Notes:       strings.TrimSpace(req.Notes),
	}); err != nil {
		slog.Error("api: update vendor", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to update vendor")
		return
	}

	vendor, _ := repo.GetByID(r.Context(), id)

	// Audit log: update vendor
	oldJSON, _ := json.Marshal(oldVendor)
	newJSON, _ := json.Marshal(vendor)
	auditRepo := repository.NewAuditRepo(pool)
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "update", "vendor", id, oldJSON, newJSON, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, vendor)
}

func (h *VendorAPIHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	oldVendor, _ := repo.GetByID(r.Context(), id)

	if err := repo.Delete(r.Context(), id); err != nil {
		slog.Error("api: delete vendor", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to delete vendor")
		return
	}

	// Audit log: delete vendor
	if oldJSON, err := json.Marshal(oldVendor); err == nil {
		auditRepo := repository.NewAuditRepo(pool)
		auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()), "delete", "vendor", id, oldJSON, nil, middleware.GetIPAddress(r))
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "deleted"})
}
