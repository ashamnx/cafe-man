package handler

import (
	"context"
	"encoding/json"
	"net/http"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// marshalAudit marshals a value to JSON for audit log entries. Returns nil on error.
func marshalAudit(v any) json.RawMessage {
	data, err := json.Marshal(v)
	if err != nil {
		return nil
	}
	return data
}

// logAudit is a convenience function for logging audit entries from handlers.
func logAudit(ctx context.Context, pool *pgxpool.Pool, r *http.Request, action, entityType string, entityID uuid.UUID, oldValues, newValues json.RawMessage) {
	repo := repository.NewAuditRepo(pool)
	repo.Log(ctx, middleware.GetUserID(ctx), middleware.GetUserName(ctx),
		action, entityType, entityID, oldValues, newValues, middleware.GetIPAddress(r))
}
