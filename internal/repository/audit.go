package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type AuditRepo struct {
	pool *pgxpool.Pool
}

func NewAuditRepo(pool *pgxpool.Pool) *AuditRepo {
	return &AuditRepo{pool: pool}
}

func (r *AuditRepo) Log(ctx context.Context, userID uuid.UUID, userName, action, entityType string, entityID uuid.UUID, oldValues, newValues json.RawMessage, ipAddress string) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO audit_log (user_id, user_name, action, entity_type, entity_id, old_values, new_values, ip_address)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		userID, userName, action, entityType, entityID, oldValues, newValues, ipAddress,
	)
	return err
}

type AuditFilter struct {
	EntityType string
	EntityID   uuid.UUID
	UserID     uuid.UUID
	Action     string
	DateFrom   time.Time
	DateTo     time.Time
	Limit      int
	Offset     int
}

func (r *AuditRepo) List(ctx context.Context, f AuditFilter) ([]model.AuditLogEntry, int, error) {
	var conditions []string
	var args []any
	argN := 1

	if f.EntityType != "" {
		conditions = append(conditions, fmt.Sprintf("entity_type = $%d", argN))
		args = append(args, f.EntityType)
		argN++
	}
	if f.EntityID != uuid.Nil {
		conditions = append(conditions, fmt.Sprintf("entity_id = $%d", argN))
		args = append(args, f.EntityID)
		argN++
	}
	if f.UserID != uuid.Nil {
		conditions = append(conditions, fmt.Sprintf("user_id = $%d", argN))
		args = append(args, f.UserID)
		argN++
	}
	if f.Action != "" {
		conditions = append(conditions, fmt.Sprintf("action = $%d", argN))
		args = append(args, f.Action)
		argN++
	}
	if !f.DateFrom.IsZero() {
		conditions = append(conditions, fmt.Sprintf("created_at >= $%d", argN))
		args = append(args, f.DateFrom)
		argN++
	}
	if !f.DateTo.IsZero() {
		conditions = append(conditions, fmt.Sprintf("created_at <= $%d", argN))
		args = append(args, f.DateTo)
		argN++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	// Count total.
	var total int
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM audit_log %s", where)
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	if f.Limit <= 0 {
		f.Limit = 50
	}

	query := fmt.Sprintf(
		`SELECT id, user_id, user_name, action, entity_type, entity_id, old_values, new_values, COALESCE(ip_address, ''), created_at
		 FROM audit_log %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		where, argN, argN+1,
	)
	args = append(args, f.Limit, f.Offset)

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var entries []model.AuditLogEntry
	for rows.Next() {
		var e model.AuditLogEntry
		if err := rows.Scan(&e.ID, &e.UserID, &e.UserName, &e.Action, &e.EntityType, &e.EntityID, &e.OldValues, &e.NewValues, &e.IPAddress, &e.CreatedAt); err != nil {
			return nil, 0, err
		}
		entries = append(entries, e)
	}
	return entries, total, rows.Err()
}

func (r *AuditRepo) GetByEntity(ctx context.Context, entityType string, entityID uuid.UUID) ([]model.AuditLogEntry, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, user_id, user_name, action, entity_type, entity_id, old_values, new_values, COALESCE(ip_address, ''), created_at
		 FROM audit_log WHERE entity_type = $1 AND entity_id = $2 ORDER BY created_at DESC`,
		entityType, entityID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []model.AuditLogEntry
	for rows.Next() {
		var e model.AuditLogEntry
		if err := rows.Scan(&e.ID, &e.UserID, &e.UserName, &e.Action, &e.EntityType, &e.EntityID, &e.OldValues, &e.NewValues, &e.IPAddress, &e.CreatedAt); err != nil {
			return nil, err
		}
		entries = append(entries, e)
	}
	return entries, rows.Err()
}
