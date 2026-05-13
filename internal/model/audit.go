package model

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type AuditLogEntry struct {
	ID         uuid.UUID       `json:"id"`
	UserID     uuid.UUID       `json:"user_id"`
	UserName   string          `json:"user_name"`
	Action     string          `json:"action"`
	EntityType string          `json:"entity_type"`
	EntityID   uuid.UUID       `json:"entity_id"`
	OldValues  json.RawMessage `json:"old_values,omitempty"`
	NewValues  json.RawMessage `json:"new_values,omitempty"`
	IPAddress  string          `json:"ip_address,omitempty"`
	CreatedAt  time.Time       `json:"created_at"`
}
