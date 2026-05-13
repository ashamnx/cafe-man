package model

import (
	"time"

	"github.com/google/uuid"
)

type MenuCategory struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	SortOrder int       `json:"sort_order"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
}

type MenuItem struct {
	ID               uuid.UUID `json:"id"`
	CategoryID       *uuid.UUID `json:"category_id"`
	Name             string    `json:"name"`
	Description      string    `json:"description"`
	ImagePath        string    `json:"image_path"`
	SellingPrice     float64   `json:"selling_price"`
	Status           string    `json:"status"`
	PreparationNotes string    `json:"preparation_notes"`
	Allergens        []string  `json:"allergens"`
	// Yield is how many portions a single batch of this recipe produces.
	// yield=1 (the default) means SellingPrice and costs are per single unit.
	// yield>1 means SellingPrice is per portion, TotalCost stays batch cost,
	// and CostPerPortion/CostMargin/NetProfit are derived per portion.
	Yield            int       `json:"yield"`
	YieldUnit        string    `json:"yield_unit"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`

	// Joined / calculated
	Category     *MenuCategory       `json:"category,omitempty"`
	Ingredients  []RecipeIngredient   `json:"ingredients,omitempty"`
	UtilityCosts []RecipeUtilityCost  `json:"utility_costs,omitempty"`
	UtilityExtras []RecipeUtilityExtra `json:"utility_extras,omitempty"`
	TotalCost      float64 `json:"total_cost"`
	CostPerPortion float64 `json:"cost_per_portion"`
	CostMargin     float64 `json:"cost_margin"`
	NetProfit      float64 `json:"net_profit"`
}

type RecipeIngredient struct {
	ID             uuid.UUID  `json:"id"`
	MenuItemID     uuid.UUID  `json:"menu_item_id"`
	IngredientID   uuid.UUID  `json:"ingredient_id"`
	Quantity       float64    `json:"quantity"`
	IngredientType string     `json:"ingredient_type"`
	Notes          string     `json:"notes"`
	DisplayUnitID  *uuid.UUID `json:"display_unit_id"`

	// Joined / computed
	Ingredient      *Ingredient `json:"ingredient,omitempty"`
	DisplayUnit     *Unit       `json:"display_unit,omitempty"`
	DisplayQuantity float64     `json:"display_quantity"`
	LineCost        float64     `json:"line_cost"`
}

// UtilityCost is a tenant-level named fixed/overhead cost shared across recipes.
type UtilityCost struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Cost        float64   `json:"cost"`
	Description string    `json:"description"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// RecipeUtilityCost is a denormalized line on a recipe's cost breakdown.
// Source is either "shared" (from utility_costs) or "extra" (from
// recipe_utility_cost_extras). ID identifies the source row for deletion.
type RecipeUtilityCost struct {
	ID     uuid.UUID `json:"id"`
	Name   string    `json:"name"`
	Cost   float64   `json:"cost"`
	Source string    `json:"source"`
}

// RecipeUtilityExtra is a per-recipe ad-hoc cost.
type RecipeUtilityExtra struct {
	ID         uuid.UUID `json:"id"`
	MenuItemID uuid.UUID `json:"menu_item_id"`
	Name       string    `json:"name"`
	Cost       float64   `json:"cost"`
	CreatedAt  time.Time `json:"created_at"`
}

// UtilityCostPriceHistory mirrors IngredientPriceHistory.
type UtilityCostPriceHistory struct {
	ID               uuid.UUID `json:"id"`
	UtilityCostID    uuid.UUID `json:"utility_cost_id"`
	OldCost          float64   `json:"old_cost"`
	NewCost          float64   `json:"new_cost"`
	ChangePercentage float64   `json:"change_percentage"`
	Source           string    `json:"source"`
	RecordedAt       time.Time `json:"recorded_at"`
}

// RecipeCostSnapshot is one entry in a recipe's cost history log. YieldAtSnapshot
// preserves the recipe's yield at snapshot time so per-portion history stays
// truthful when the yield is later edited.
type RecipeCostSnapshot struct {
	ID              uuid.UUID `json:"id"`
	MenuItemID      uuid.UUID `json:"menu_item_id"`
	TotalCost       float64   `json:"total_cost"`
	IngredientCost  float64   `json:"ingredient_cost"`
	UtilityCost     float64   `json:"utility_cost"`
	YieldAtSnapshot int       `json:"yield_at_snapshot"`
	Reason          string    `json:"reason"`
	SnapshotAt      time.Time `json:"snapshot_at"`
}
