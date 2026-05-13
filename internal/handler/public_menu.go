package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"searlo-cafe/internal/database"
	"searlo-cafe/internal/repository"

	"github.com/jackc/pgx/v5/pgxpool"
)

// PublicMenuHandler serves the unauthenticated /menu/{slug} page that shows a
// cafe's active recipes to customers. It looks up the organization by slug on
// the platform DB, then opens that org's tenant pool to fetch active recipes.
type PublicMenuHandler struct {
	render    *Renderer
	orgRepo   *repository.OrganizationRepo
	tenantMgr *database.TenantManager
}

func NewPublicMenuHandler(render *Renderer, platformPool *pgxpool.Pool, tenantMgr *database.TenantManager) *PublicMenuHandler {
	return &PublicMenuHandler{
		render:    render,
		orgRepo:   repository.NewOrganizationRepo(platformPool),
		tenantMgr: tenantMgr,
	}
}

func (h *PublicMenuHandler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /menu/{slug}", h.show)
}

func (h *PublicMenuHandler) show(w http.ResponseWriter, r *http.Request) {
	slug := r.PathValue("slug")
	if slug == "" {
		http.NotFound(w, r)
		return
	}

	org, err := h.orgRepo.GetBySlug(r.Context(), slug)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			http.NotFound(w, r)
			return
		}
		slog.Error("public menu: org lookup", "slug", slug, "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	if !org.IsActive {
		http.NotFound(w, r)
		return
	}

	pool, err := h.tenantMgr.Pool(r.Context(), org.DBName)
	if err != nil {
		slog.Error("public menu: tenant pool", "slug", slug, "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	groups, err := GroupActiveMenu(r.Context(), repository.NewRecipeRepo(pool))
	if err != nil {
		slog.Error("public menu: list recipes", "slug", slug, "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Cache-Control", "public, max-age=300")

	h.render.HTML(w, r, "public_menu.html", map[string]any{
		"Org":            org,
		"Groups":         groups,
		"CurrencySymbol": org.CurrencySymbol,
		"Title":          org.Name + " — Menu",
	})
}
