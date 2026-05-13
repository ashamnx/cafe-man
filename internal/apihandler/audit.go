package apihandler

import (
	"log/slog"
	"net/http"
	"strconv"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
)

type AuditAPIHandler struct{}

func NewAuditAPIHandler() *AuditAPIHandler {
	return &AuditAPIHandler{}
}

func (h *AuditAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/audit-log", wrap(h.list, "audit_log", "read"))
}

func (h *AuditAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewAuditRepo(pool)

	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(q.Get("limit"))
	if limit <= 0 || limit > 100 {
		limit = 50
	}

	filter := repository.AuditFilter{
		EntityType: q.Get("entity_type"),
		Action:     q.Get("action"),
		Limit:      limit,
		Offset:     (page - 1) * limit,
	}

	if uidStr := q.Get("user_id"); uidStr != "" {
		if uid, err := uuid.Parse(uidStr); err == nil {
			filter.UserID = uid
		}
	}

	entries, total, err := repo.List(r.Context(), filter)
	if err != nil {
		slog.Error("api: list audit log", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list audit log")
		return
	}

	totalPages := (total + limit - 1) / limit
	if totalPages < 1 {
		totalPages = 1
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"entries":      entries,
		"total":        total,
		"page":         page,
		"total_pages":  totalPages,
		"per_page":     limit,
	})
}
