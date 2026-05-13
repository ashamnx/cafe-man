package apihandler

import (
	"log/slog"
	"net/http"
	"time"

	"searlo-cafe/internal/middleware"

	"github.com/google/uuid"
)

type AlertAPIHandler struct{}

func NewAlertAPIHandler() *AlertAPIHandler {
	return &AlertAPIHandler{}
}

func (h *AlertAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/alerts", wrap(h.list))
	mux.Handle("POST /api/v1/alerts/{id}/read", wrap(h.markRead))
}

func (h *AlertAPIHandler) list(w http.ResponseWriter, r *http.Request) {
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
		slog.Error("api: list alerts", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list alerts")
		return
	}
	defer rows.Close()

	type alertResponse struct {
		ID              uuid.UUID `json:"id"`
		AlertType       string    `json:"alert_type"`
		IngredientName  string    `json:"ingredient_name"`
		Message         string    `json:"message"`
		IsRead          bool      `json:"is_read"`
		CreatedAt       time.Time `json:"created_at"`
		AffectedRecipes int       `json:"affected_recipes"`
	}

	var alerts []alertResponse
	for rows.Next() {
		var a alertResponse
		if err := rows.Scan(&a.ID, &a.AlertType, &a.Message, &a.IsRead, &a.CreatedAt, &a.IngredientName, &a.AffectedRecipes); err != nil {
			slog.Error("scan alert", "error", err)
			continue
		}
		alerts = append(alerts, a)
	}

	if alerts == nil {
		alerts = []alertResponse{}
	}

	writeJSON(w, http.StatusOK, alerts)
}

func (h *AlertAPIHandler) markRead(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	alertID := r.PathValue("id")

	_, err := pool.Exec(r.Context(), `UPDATE alerts SET is_read = true WHERE id = $1`, alertID)
	if err != nil {
		slog.Error("api: mark alert read", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to mark alert as read")
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"message": "marked as read"})
}
