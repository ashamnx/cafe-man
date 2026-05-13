package model

import (
	"time"

	"github.com/google/uuid"
)

type SaleEntry struct {
	ID        uuid.UUID `json:"id"`
	SaleDate  time.Time `json:"sale_date"`
	Notes     string    `json:"notes"`
	Status    string    `json:"status"`
	CreatedBy uuid.UUID `json:"created_by"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Joined / aggregated
	Items      []SaleEntryItem `json:"items,omitempty"`
	TotalItems int             `json:"total_items"`
	TotalValue float64         `json:"total_value"`
}

type SaleEntryItem struct {
	ID           uuid.UUID `json:"id"`
	SaleEntryID  uuid.UUID `json:"sale_entry_id"`
	MenuItemID   uuid.UUID `json:"menu_item_id"`
	Quantity     int       `json:"quantity"`
	SellingPrice float64   `json:"selling_price"`
	CreatedAt    time.Time `json:"created_at"`

	// Joined
	MenuItemName string `json:"menu_item_name"`
}

type SaleEntryDeduction struct {
	ID              uuid.UUID `json:"id"`
	SaleEntryID     uuid.UUID `json:"sale_entry_id"`
	SaleEntryItemID uuid.UUID `json:"sale_entry_item_id"`
	IngredientID    uuid.UUID `json:"ingredient_id"`
	QuantityPerUnit float64   `json:"quantity_per_unit"`
	TotalQuantity   float64   `json:"total_quantity"`
	CreatedAt       time.Time `json:"created_at"`

	// Joined
	IngredientName string `json:"ingredient_name"`
	UnitAbbr       string `json:"unit_abbr"`
}

type WastageRecord struct {
	ID           uuid.UUID `json:"id"`
	IngredientID uuid.UUID `json:"ingredient_id"`
	Quantity     float64   `json:"quantity"`
	WastageType  string    `json:"wastage_type"`
	WastageDate  time.Time `json:"wastage_date"`
	Notes        string    `json:"notes"`
	CreatedBy    uuid.UUID `json:"created_by"`
	CreatedAt    time.Time `json:"created_at"`

	// Joined
	IngredientName string `json:"ingredient_name"`
	UnitAbbr       string `json:"unit_abbr"`
}

type StockMovement struct {
	ID            uuid.UUID  `json:"id"`
	IngredientID  uuid.UUID  `json:"ingredient_id"`
	Quantity      float64    `json:"quantity"`
	MovementType  string     `json:"movement_type"`
	ReferenceType string     `json:"reference_type"`
	ReferenceID   *uuid.UUID `json:"reference_id"`
	Notes         string     `json:"notes"`
	CreatedBy     uuid.UUID  `json:"created_by"`
	CreatedAt     time.Time  `json:"created_at"`

	// Joined
	IngredientName string `json:"ingredient_name"`
	UnitAbbr       string `json:"unit_abbr"`
}
