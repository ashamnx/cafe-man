package handler

import (
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
)

type VendorHandler struct {
	render *Renderer
}

func NewVendorHandler(render *Renderer) *VendorHandler {
	return &VendorHandler{render: render}
}

func (h *VendorHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /vendors", wrap(h.list, "vendors", "read"))
	mux.Handle("GET /vendors/new", wrap(h.showCreate, "vendors", "create"))
	mux.Handle("POST /vendors", wrap(h.create, "vendors", "create"))
	mux.Handle("GET /vendors/{id}", wrap(h.show, "vendors", "read"))
	mux.Handle("GET /vendors/{id}/edit", wrap(h.showEdit, "vendors", "update"))
	mux.Handle("PUT /vendors/{id}", wrap(h.update, "vendors", "update"))
	mux.Handle("DELETE /vendors/{id}", wrap(h.delete, "vendors", "delete"))
}

func (h *VendorHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	q := r.URL.Query()
	search := q.Get("search")
	sortBy := q.Get("sort")

	vendors, err := repo.List(r.Context(), search, sortBy)
	if err != nil {
		slog.Error("list vendors", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	ingredientCounts, _ := repo.GetIngredientCountsByVendor(r.Context())

	h.render.HTML(w, r, "vendors.html", map[string]any{
		"Vendors":          vendors,
		"IngredientCounts": ingredientCounts,
		"Filters":          map[string]string{"search": search, "sort": sortBy},
		"Title":            "Vendors",
	})
}

func (h *VendorHandler) showCreate(w http.ResponseWriter, r *http.Request) {
	h.render.HTML(w, r, "vendor_form.html", map[string]any{"Title": "Add Vendor"})
}

func (h *VendorHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	params := repository.CreateVendorParams{
		Name:        strings.TrimSpace(r.FormValue("name")),
		ContactName: strings.TrimSpace(r.FormValue("contact_name")),
		Phone:       strings.TrimSpace(r.FormValue("phone")),
		Email:       strings.TrimSpace(r.FormValue("email")),
		Address:     strings.TrimSpace(r.FormValue("address")),
		Notes:       strings.TrimSpace(r.FormValue("notes")),
	}

	if params.Name == "" {
		h.render.HTML(w, r, "vendor_form.html", map[string]any{"Error": "Name is required", "Input": params})
		return
	}

	vendor, err := repo.Create(r.Context(), params)
	if err != nil {
		slog.Error("create vendor", "error", err)
		h.render.HTML(w, r, "vendor_form.html", map[string]any{"Error": "Failed to create vendor", "Input": params})
		return
	}

	logAudit(r.Context(), pool, r, "create", "vendor", vendor.ID, nil, marshalAudit(vendor))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/vendors")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/vendors", http.StatusSeeOther)
}

func (h *VendorHandler) show(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	vendor, err := repo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	h.render.HTML(w, r, "vendor_detail.html", map[string]any{
		"Vendor": vendor,
		"Title":  vendor.Name,
	})
}

func (h *VendorHandler) showEdit(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	vendor, err := repo.GetByID(r.Context(), id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	h.render.HTML(w, r, "vendor_form.html", map[string]any{
		"Vendor": vendor,
		"Title":  "Edit " + vendor.Name,
		"IsEdit": true,
	})
}

func (h *VendorHandler) update(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	params := repository.CreateVendorParams{
		Name:        strings.TrimSpace(r.FormValue("name")),
		ContactName: strings.TrimSpace(r.FormValue("contact_name")),
		Phone:       strings.TrimSpace(r.FormValue("phone")),
		Email:       strings.TrimSpace(r.FormValue("email")),
		Address:     strings.TrimSpace(r.FormValue("address")),
		Notes:       strings.TrimSpace(r.FormValue("notes")),
	}

	oldVendor, _ := repo.GetByID(r.Context(), id)

	if err := repo.Update(r.Context(), id, params); err != nil {
		slog.Error("update vendor", "error", err)
		http.Error(w, "Failed to update", http.StatusInternalServerError)
		return
	}

	newVendor, _ := repo.GetByID(r.Context(), id)
	logAudit(r.Context(), pool, r, "update", "vendor", id, marshalAudit(oldVendor), marshalAudit(newVendor))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/vendors/"+id.String())
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/vendors/"+id.String(), http.StatusSeeOther)
}

func (h *VendorHandler) delete(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewVendorRepo(pool)

	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	oldVendor, _ := repo.GetByID(r.Context(), id)

	if err := repo.Delete(r.Context(), id); err != nil {
		slog.Error("delete vendor", "error", err)
		http.Error(w, "Failed to delete", http.StatusInternalServerError)
		return
	}

	logAudit(r.Context(), pool, r, "delete", "vendor", id, marshalAudit(oldVendor), nil)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/vendors")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/vendors", http.StatusSeeOther)
}
