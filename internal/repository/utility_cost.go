package repository

import (
	"context"
	"errors"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// UtilityCostRepo manages tenant-level shared utility costs (electricity,
// gas, prep labor, etc.). Mirrors IngredientRepo conventions.
type UtilityCostRepo struct {
	pool *pgxpool.Pool
}

func NewUtilityCostRepo(pool *pgxpool.Pool) *UtilityCostRepo {
	return &UtilityCostRepo{pool: pool}
}

func (r *UtilityCostRepo) List(ctx context.Context, includeInactive bool) ([]model.UtilityCost, error) {
	query := `SELECT id, name, cost, COALESCE(description,''), is_active, created_at, updated_at
	          FROM utility_costs`
	if !includeInactive {
		query += ` WHERE is_active = true`
	}
	query += ` ORDER BY name`

	rows, err := r.pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var costs []model.UtilityCost
	for rows.Next() {
		var c model.UtilityCost
		if err := rows.Scan(&c.ID, &c.Name, &c.Cost, &c.Description, &c.IsActive, &c.CreatedAt, &c.UpdatedAt); err != nil {
			return nil, err
		}
		costs = append(costs, c)
	}
	return costs, rows.Err()
}

func (r *UtilityCostRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.UtilityCost, error) {
	var c model.UtilityCost
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, cost, COALESCE(description,''), is_active, created_at, updated_at
		 FROM utility_costs WHERE id = $1`, id,
	).Scan(&c.ID, &c.Name, &c.Cost, &c.Description, &c.IsActive, &c.CreatedAt, &c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *UtilityCostRepo) Create(ctx context.Context, name, description string, cost float64) (*model.UtilityCost, error) {
	var c model.UtilityCost
	err := r.pool.QueryRow(ctx,
		`INSERT INTO utility_costs (name, cost, description)
		 VALUES ($1, $2, NULLIF($3,''))
		 RETURNING id, name, cost, COALESCE(description,''), is_active, created_at, updated_at`,
		name, cost, description,
	).Scan(&c.ID, &c.Name, &c.Cost, &c.Description, &c.IsActive, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, err
	}
	// First appearance: record as history row from 0 → cost so the price
	// timeline starts cleanly (mirrors ingredient creation behavior).
	_ = r.recordPriceChange(ctx, c.ID, 0, cost, "manual")
	return &c, nil
}

// Update changes name/description/cost. Returns the previous cost so the
// caller can trigger recipe snapshots if it actually changed.
func (r *UtilityCostRepo) Update(ctx context.Context, id uuid.UUID, name, description string, cost float64) (oldCost float64, err error) {
	err = r.pool.QueryRow(ctx,
		`WITH prev AS (SELECT cost FROM utility_costs WHERE id = $1)
		 UPDATE utility_costs
		 SET name = $2, description = NULLIF($3,''), cost = $4, updated_at = NOW()
		 WHERE id = $1
		 RETURNING (SELECT cost FROM prev)`,
		id, name, description, cost,
	).Scan(&oldCost)
	return oldCost, err
}

func (r *UtilityCostRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM utility_costs WHERE id = $1`, id)
	return err
}

// RecordPriceChange appends a row to utility_cost_price_history.
func (r *UtilityCostRepo) RecordPriceChange(ctx context.Context, id uuid.UUID, oldCost, newCost float64, source string) error {
	return r.recordPriceChange(ctx, id, oldCost, newCost, source)
}

func (r *UtilityCostRepo) recordPriceChange(ctx context.Context, id uuid.UUID, oldCost, newCost float64, source string) error {
	changePct := float64(0)
	if oldCost > 0 {
		changePct = ((newCost - oldCost) / oldCost) * 100
	}
	_, err := r.pool.Exec(ctx,
		`INSERT INTO utility_cost_price_history (utility_cost_id, old_cost, new_cost, change_percentage, source)
		 VALUES ($1, $2, $3, $4, $5)`,
		id, oldCost, newCost, changePct, source,
	)
	return err
}

// GetPriceHistory returns recent price changes for a single utility cost.
func (r *UtilityCostRepo) GetPriceHistory(ctx context.Context, id uuid.UUID) ([]model.UtilityCostPriceHistory, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, utility_cost_id, old_cost, new_cost, change_percentage, source, recorded_at
		 FROM utility_cost_price_history
		 WHERE utility_cost_id = $1
		 ORDER BY recorded_at DESC
		 LIMIT 50`,
		id,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var history []model.UtilityCostPriceHistory
	for rows.Next() {
		var h model.UtilityCostPriceHistory
		if err := rows.Scan(&h.ID, &h.UtilityCostID, &h.OldCost, &h.NewCost, &h.ChangePercentage, &h.Source, &h.RecordedAt); err != nil {
			return nil, err
		}
		history = append(history, h)
	}
	return history, rows.Err()
}

// RecipesUsingCost returns menu_item IDs currently linked to a utility cost.
// Used by the update flow to snapshot every affected recipe.
func (r *UtilityCostRepo) RecipesUsingCost(ctx context.Context, id uuid.UUID) ([]uuid.UUID, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT menu_item_id FROM recipe_utility_costs WHERE utility_cost_id = $1`,
		id,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []uuid.UUID
	for rows.Next() {
		var mid uuid.UUID
		if err := rows.Scan(&mid); err != nil {
			return nil, err
		}
		ids = append(ids, mid)
	}
	return ids, rows.Err()
}
