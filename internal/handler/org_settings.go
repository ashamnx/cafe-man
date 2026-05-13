package handler

import (
	"log/slog"
	"net/http"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/storage"

	"github.com/alexedwards/scs/v2"
	"github.com/jackc/pgx/v5/pgxpool"
)

type OrgSettingsHandler struct {
	render       *Renderer
	platformPool *pgxpool.Pool
	store        *storage.ImageStore
	sessions     *scs.SessionManager
}

func NewOrgSettingsHandler(render *Renderer, platformPool *pgxpool.Pool, store *storage.ImageStore, sessions *scs.SessionManager) *OrgSettingsHandler {
	return &OrgSettingsHandler{render: render, platformPool: platformPool, store: store, sessions: sessions}
}

func (h *OrgSettingsHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /settings/organization", wrap(h.show, "users", "read"))
	mux.Handle("POST /settings/organization/logo", wrap(h.uploadLogo, "users", "update"))
	mux.Handle("POST /settings/organization/logo/remove", wrap(h.removeLogo, "users", "update"))
}

func (h *OrgSettingsHandler) show(w http.ResponseWriter, r *http.Request) {
	orgID := middleware.GetOrgID(r.Context())
	orgRepo := repository.NewOrganizationRepo(h.platformPool)

	org, err := orgRepo.GetByID(r.Context(), orgID)
	if err != nil {
		slog.Error("load org", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.HTML(w, r, "org_settings.html", map[string]any{
		"Org":   org,
		"Title": "Organization Settings",
	})
}

func (h *OrgSettingsHandler) uploadLogo(w http.ResponseWriter, r *http.Request) {
	if h.store == nil {
		http.Error(w, "Image storage not configured", http.StatusServiceUnavailable)
		return
	}

	if err := r.ParseMultipartForm(5 << 20); err != nil {
		http.Error(w, "File too large", http.StatusBadRequest)
		return
	}

	file, header, err := r.FormFile("logo")
	if err != nil {
		http.Error(w, "No file uploaded", http.StatusBadRequest)
		return
	}
	defer file.Close()

	orgID := middleware.GetOrgID(r.Context())
	orgDB := middleware.GetOrgDB(r.Context())

	key, err := h.store.Upload(r.Context(), orgDB, "logos", file, header.Filename)
	if err != nil {
		slog.Error("upload logo", "error", err)
		http.Error(w, "Upload failed", http.StatusInternalServerError)
		return
	}

	orgRepo := repository.NewOrganizationRepo(h.platformPool)

	// Delete old logo asset if any.
	if old, _ := orgRepo.GetByID(r.Context(), orgID); old != nil && old.LogoImageKey != "" {
		_ = h.store.Delete(r.Context(), old.LogoImageKey)
	}

	if err := orgRepo.UpdateLogo(r.Context(), orgID, key); err != nil {
		slog.Error("persist logo key", "error", err)
		http.Error(w, "Failed to save logo", http.StatusInternalServerError)
		return
	}

	h.sessions.Put(r.Context(), "org_logo_key", key)

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/organization")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/settings/organization", http.StatusSeeOther)
}

func (h *OrgSettingsHandler) removeLogo(w http.ResponseWriter, r *http.Request) {
	orgID := middleware.GetOrgID(r.Context())
	orgRepo := repository.NewOrganizationRepo(h.platformPool)

	org, err := orgRepo.GetByID(r.Context(), orgID)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	if org.LogoImageKey != "" && h.store != nil {
		_ = h.store.Delete(r.Context(), org.LogoImageKey)
	}

	if err := orgRepo.UpdateLogo(r.Context(), orgID, ""); err != nil {
		slog.Error("clear logo", "error", err)
		http.Error(w, "Failed to remove logo", http.StatusInternalServerError)
		return
	}

	h.sessions.Put(r.Context(), "org_logo_key", "")

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/organization")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/settings/organization", http.StatusSeeOther)
}
