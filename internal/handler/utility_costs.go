package handler

import (
	"fmt"
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
)

// UtilityCostsHandler serves the tenant-level "Utility & Fixed Costs"
// management page under Settings.
type UtilityCostsHandler struct {
	render *Renderer
}

func NewUtilityCostsHandler(render *Renderer) *UtilityCostsHandler {
	return &UtilityCostsHandler{render: render}
}

func (h *UtilityCostsHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /settings/utility-costs", wrap(h.list, "menu_items", "read"))
	mux.Handle("POST /settings/utility-costs", wrap(h.create, "menu_items", "update"))
	mux.Handle("POST /settings/utility-costs/{id}", wrap(h.update, "menu_items", "update"))
	mux.Handle("DELETE /settings/utility-costs/{id}", wrap(h.delete, "menu_items", "update"))
}

func (h *UtilityCostsHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewUtilityCostRepo(pool)

	costs, err := repo.List(r.Context(), true)
	if err != nil {
		slog.Error("list utility costs", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	h.render.HTML(w, r, "utility_costs.html", map[string]any{
		"Costs": costs,
		"Title": "Utility & Fixed Costs",
	})
}

func (h *UtilityCostsHandler) create(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}
	name := strings.TrimSpace(r.FormValue("name"))
	if name == "" {
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	cost := parseFloat(r.FormValue("cost"))
	description := strings.TrimSpace(r.FormValue("description"))

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewUtilityCostRepo(pool)
	if _, err := repo.Create(r.Context(), name, description, cost); err != nil {
		if strings.Contains(err.Error(), "duplicate key") {
			http.Error(w, "A cost with this name already exists", http.StatusConflict)
			return
		}
		slog.Error("create utility cost", "error", err)
		http.Error(w, "Failed to create cost", http.StatusInternalServerError)
		return
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/utility-costs")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/settings/utility-costs", http.StatusSeeOther)
}

func (h *UtilityCostsHandler) update(w http.ResponseWriter, r *http.Request) {
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
		http.Error(w, "Name is required", http.StatusBadRequest)
		return
	}
	cost := parseFloat(r.FormValue("cost"))
	description := strings.TrimSpace(r.FormValue("description"))

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewUtilityCostRepo(pool)

	oldCost, err := repo.Update(r.Context(), id, name, description, cost)
	if err != nil {
		slog.Error("update utility cost", "error", err)
		http.Error(w, "Failed to update cost", http.StatusInternalServerError)
		return
	}

	// If cost actually changed, record history + snapshot every recipe using it.
	if oldCost != cost {
		if err := repo.RecordPriceChange(r.Context(), id, oldCost, cost, "manual"); err != nil {
			slog.Error("record utility cost price change", "error", err)
		}
		recipeRepo := repository.NewRecipeRepo(pool)
		reason := fmt.Sprintf("%s cost %.2f → %.2f", name, oldCost, cost)
		if err := recipeRepo.SnapshotRecipesUsingUtilityCost(r.Context(), id, reason); err != nil {
			slog.Error("snapshot recipes using utility cost", "error", err)
		}
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/utility-costs")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/settings/utility-costs", http.StatusSeeOther)
}

func (h *UtilityCostsHandler) delete(w http.ResponseWriter, r *http.Request) {
	id, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}

	pool := middleware.TenantPool(r.Context())
	repo := repository.NewUtilityCostRepo(pool)
	recipeRepo := repository.NewRecipeRepo(pool)

	// Look up name + recipes using this cost BEFORE deleting, so we can
	// snapshot them afterward with a useful reason string.
	cost, _ := repo.GetByID(r.Context(), id)
	affected, _ := repo.RecipesUsingCost(r.Context(), id)

	if err := repo.Delete(r.Context(), id); err != nil {
		slog.Error("delete utility cost", "error", err)
		http.Error(w, "Failed to delete cost", http.StatusInternalServerError)
		return
	}

	// After cascade-unlink, snapshot every affected recipe.
	if cost != nil {
		reason := fmt.Sprintf("-%s unlinked (cost deleted)", cost.Name)
		for _, mid := range affected {
			if err := recipeRepo.SnapshotRecipe(r.Context(), mid, reason); err != nil {
				slog.Error("snapshot after utility cost delete", "error", err)
			}
		}
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/utility-costs")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/settings/utility-costs", http.StatusSeeOther)
}
