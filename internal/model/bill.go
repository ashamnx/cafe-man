package model

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type VendorBill struct {
	ID             uuid.UUID       `json:"id"`
	VendorID       *uuid.UUID      `json:"vendor_id"`
	BillNumber     string          `json:"bill_number"`
	BillDate       *time.Time      `json:"bill_date"`
	TotalAmount    *float64        `json:"total_amount"`
	ImagePath      string          `json:"image_path"`
	EntryType      string          `json:"entry_type"`
	AIRawResponse  json.RawMessage `json:"ai_raw_response"`
	Status         string          `json:"status"`
	Notes          string          `json:"notes"`
	CreatedBy      uuid.UUID       `json:"created_by"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`

	// Computed
	ItemCount int `json:"item_count"`

	// Joined
	Vendor *Vendor          `json:"vendor,omitempty"`
	Items  []VendorBillItem `json:"items,omitempty"`
}

type VendorBillItem struct {
	ID            uuid.UUID  `json:"id"`
	BillID        uuid.UUID  `json:"bill_id"`
	RawItemName   string     `json:"raw_item_name"`
	RawQuantity   *float64   `json:"raw_quantity"`
	RawUnit       string     `json:"raw_unit"`
	RawUnitPrice  *float64   `json:"raw_unit_price"`
	RawTotalPrice *float64   `json:"raw_total_price"`
	IngredientID    *uuid.UUID `json:"ingredient_id"`
	BillUnitID      *uuid.UUID `json:"bill_unit_id"`
	MappedQuantity  *float64   `json:"mapped_quantity"`
	MappedUnitPrice *float64   `json:"mapped_unit_price"`
	MappingStatus   string     `json:"mapping_status"`
	MappedAt      *time.Time `json:"mapped_at"`
	CreatedAt     time.Time  `json:"created_at"`

	// Joined
	Ingredient *Ingredient `json:"ingredient,omitempty"`
}

// AIBillExtraction is the structured output expected from the AI scanner.
type AIBillExtraction struct {
	VendorName  string              `json:"vendor_name"`
	BillNumber  string              `json:"bill_number"`
	BillDate    string              `json:"bill_date"`
	TotalAmount *float64            `json:"total_amount"`
	Items       []AIBillLineItem    `json:"items"`
}

type AIBillLineItem struct {
	Name      string   `json:"name"`
	Quantity  *float64 `json:"quantity"`
	Unit      string   `json:"unit"`
	UnitPrice *float64 `json:"unit_price"`
	Total     *float64 `json:"total"`
}
