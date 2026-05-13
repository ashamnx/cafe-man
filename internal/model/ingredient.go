package model

import (
	"time"

	"github.com/google/uuid"
)

type Unit struct {
	ID               uuid.UUID `json:"id"`
	Name             string    `json:"name"`
	Abbreviation     string    `json:"abbreviation"`
	UnitType         string    `json:"unit_type"`
	BaseUnitID       *uuid.UUID `json:"base_unit_id"`
	ConversionFactor *float64  `json:"conversion_factor"`
	CreatedAt        time.Time `json:"created_at"`
}

type IngredientCategory struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	SortOrder int       `json:"sort_order"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
}

type Ingredient struct {
	ID                   uuid.UUID  `json:"id"`
	Name                 string     `json:"name"`
	Description          string     `json:"description"`
	ImagePath            string     `json:"image_path"`
	UnitID               uuid.UUID  `json:"unit_id"`
	CurrentStock         float64    `json:"current_stock"`
	CurrentCostPerUnit   float64    `json:"current_cost_per_unit"`
	LowStockThreshold    *float64   `json:"low_stock_threshold"`
	PriceAlertPercentage float64    `json:"price_alert_percentage"`
	CategoryID           *uuid.UUID `json:"category_id"`
	IsActive             bool       `json:"is_active"`
	CreatedAt            time.Time  `json:"created_at"`
	UpdatedAt            time.Time  `json:"updated_at"`

	// Persisted bulk-purchase defaults (entered via the purchase calculator).
	// Used as fallback when no mapped vendor_bill_items row exists.
	PurchaseQty     *float64   `json:"purchase_qty,omitempty"`
	PurchaseUnitID  *uuid.UUID `json:"purchase_unit_id,omitempty"`
	PurchasePrice   *float64   `json:"purchase_price,omitempty"`

	// Joined fields
	Unit        *Unit               `json:"unit,omitempty"`
	Category    *IngredientCategory `json:"category,omitempty"`
	LastPriceAt *time.Time          `json:"last_price_at,omitempty"`

	// Effective bulk price for list display: either the latest mapped vendor
	// bill item, or the saved purchase defaults above. Populated only by List.
	BulkQty       *float64 `json:"bulk_qty,omitempty"`
	BulkUnitAbbr  string   `json:"bulk_unit_abbr,omitempty"`
	BulkTotal     *float64 `json:"bulk_total,omitempty"`
}

type IngredientPriceHistory struct {
	ID               uuid.UUID `json:"id"`
	IngredientID     uuid.UUID `json:"ingredient_id"`
	OldCostPerUnit   float64   `json:"old_cost_per_unit"`
	NewCostPerUnit   float64   `json:"new_cost_per_unit"`
	ChangePercentage float64   `json:"change_percentage"`
	Source           string    `json:"source"`
	BillID           *uuid.UUID `json:"bill_id"`
	RecordedAt       time.Time `json:"recorded_at"`
}
