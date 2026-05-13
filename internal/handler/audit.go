package handler

import (
	"log/slog"
	"net/http"
	"strconv"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
)

const auditPageSize = 50

type AuditHandler struct {
	render *Renderer
}

func NewAuditHandler(render *Renderer) *AuditHandler {
	return &AuditHandler{render: render}
}

func (h *AuditHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
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

	mux.Handle("GET /audit-log", wrap(h.list, "audit_log", "read"))
}

func (h *AuditHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	repo := repository.NewAuditRepo(pool)

	q := r.URL.Query()
	entityType := q.Get("entity_type")
	action := q.Get("action")

	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}

	filter := repository.AuditFilter{
		EntityType: entityType,
		Action:     action,
		Limit:      auditPageSize,
		Offset:     (page - 1) * auditPageSize,
	}

	entries, total, err := repo.List(r.Context(), filter)
	if err != nil {
		slog.Error("failed to list audit log", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	totalPages := (total + auditPageSize - 1) / auditPageSize
	if totalPages < 1 {
		totalPages = 1
	}

	data := map[string]any{
		"Title":            "Audit Log",
		"Entries":          entries,
		"FilterEntityType": entityType,
		"FilterAction":     action,
		"CurrentPage":      page,
		"TotalPages":       totalPages,
		"TotalEntries":     total,
	}
	h.render.HTML(w, r, "audit_log.html", data)
}
