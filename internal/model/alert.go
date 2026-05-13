package model

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type Alert struct {
	ID           uuid.UUID       `json:"id"`
	AlertType    string          `json:"alert_type"`
	IngredientID uuid.UUID       `json:"ingredient_id"`
	Message      string          `json:"message"`
	Details      json.RawMessage `json:"details"`
	IsRead       bool            `json:"is_read"`
	CreatedAt    time.Time       `json:"created_at"`

	// Joined
	Ingredient *Ingredient `json:"ingredient,omitempty"`
}
