package handler

import (
	"log/slog"
	"net/http"
	"time"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
)

type DashboardHandler struct {
	render *Renderer
}

func NewDashboardHandler(render *Renderer) *DashboardHandler {
	return &DashboardHandler{render: render}
}

func (h *DashboardHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
	chain := func(handler http.HandlerFunc) http.Handler {
		var h http.Handler = handler
		h = tenantMw(h)
		h = orgMw(h)
		h = authMw(h)
		return h
	}

	mux.Handle("GET /dashboard", chain(h.dashboard))
	mux.Handle("GET /alerts", chain(h.alerts))
	mux.Handle("POST /alerts/{id}/read", chain(h.markAlertRead))
}

func (h *DashboardHandler) dashboard(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	ingredientRepo := repository.NewIngredientRepo(pool)
	menuRepo := repository.NewRecipeRepo(pool)
	vendorRepo := repository.NewVendorRepo(pool)

	stockRepo := repository.NewStockRepo(pool)

	ingredients, _ := ingredientRepo.List(r.Context(), "", nil, "", "")
	lowStock, _ := ingredientRepo.GetLowStockIngredients(r.Context())
	menuItems, _ := menuRepo.ListRecipes(r.Context(), "", "", "", "", nil)
	vendors, _ := vendorRepo.List(r.Context(), "", "")
	alertCount, _ := menuRepo.GetUnreadAlertCount(r.Context())
	recentMovements, _ := stockRepo.ListStockMovements(r.Context(), "", "", 5)

	h.render.HTML(w, r, "dashboard.html", map[string]any{
		"Title":           "Dashboard",
		"IngredientCount": len(ingredients),
		"RecipeCount":     len(menuItems),
		"VendorCount":     len(vendors),
		"LowStock":        lowStock,
		"AlertCount":      alertCount,
		"RecentMovements": recentMovements,
	})
}

func (h *DashboardHandler) alerts(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	rows, err := pool.Query(r.Context(),
		`SELECT a.id, a.alert_type, a.message, a.is_read, a.created_at,
		        i.name,
		        (SELECT COUNT(DISTINCT ri.menu_item_id) FROM recipe_ingredients ri
		         JOIN menu_items m ON m.id = ri.menu_item_id AND m.status != 'deleted'
		         WHERE ri.ingredient_id = a.ingredient_id) as affected_recipes
		 FROM alerts a
		 JOIN ingredients i ON i.id = a.ingredient_id
		 ORDER BY a.is_read ASC, a.created_at DESC
		 LIMIT 100`)
	if err != nil {
		slog.Error("list alerts", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type alertView struct {
		ID              string
		AlertType       string
		IngredientName  string
		Message         string
		IsRead          bool
		CreatedAt       time.Time
		AffectedRecipes float64
	}

	var alerts []alertView
	for rows.Next() {
		var a alertView
		var affected int
		if err := rows.Scan(&a.ID, &a.AlertType, &a.Message, &a.IsRead, &a.CreatedAt, &a.IngredientName, &affected); err != nil {
			slog.Error("scan alert", "error", err)
			continue
		}
		a.AffectedRecipes = float64(affected)
		alerts = append(alerts, a)
	}

	h.render.HTML(w, r, "alerts.html", map[string]any{
		"Alerts": alerts,
		"Title":  "Alerts",
	})
}

func (h *DashboardHandler) markAlertRead(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	alertID := r.PathValue("id")

	_, err := pool.Exec(r.Context(),
		`UPDATE alerts SET is_read = true WHERE id = $1`, alertID)
	if err != nil {
		slog.Error("mark alert read", "error", err)
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/alerts")
		w.WriteHeader(http.StatusNoContent)
		return
	}
	http.Redirect(w, r, "/alerts", http.StatusSeeOther)
}
