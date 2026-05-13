package apihandler

import (
	"net/http"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
)

type DashboardAPIHandler struct{}

func NewDashboardAPIHandler() *DashboardAPIHandler {
	return &DashboardAPIHandler{}
}

func (h *DashboardAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/dashboard", wrap(h.dashboard))
}

func (h *DashboardAPIHandler) dashboard(w http.ResponseWriter, r *http.Request) {
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

	writeJSON(w, http.StatusOK, map[string]any{
		"ingredient_count": len(ingredients),
		"recipe_count":     len(menuItems),
		"vendor_count":     len(vendors),
		"low_stock_count":  len(lowStock),
		"low_stock":        lowStock,
		"unread_alerts":    alertCount,
		"recent_movements": recentMovements,
	})
}
