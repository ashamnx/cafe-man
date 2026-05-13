package repository

import (
	"context"
	"errors"
	"fmt"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type IngredientRepo struct {
	pool *pgxpool.Pool
}

func NewIngredientRepo(pool *pgxpool.Pool) *IngredientRepo {
	return &IngredientRepo{pool: pool}
}

func (r *IngredientRepo) List(ctx context.Context, search string, categoryID *uuid.UUID, sortBy, stockFilter string) ([]model.Ingredient, error) {
	// bi: latest mapped bill item for the ingredient (most-recent purchase).
	// pu: unit row for the ingredient's saved initial purchase_unit_id.
	// COALESCE picks the bill value first, falling back to the persisted
	// initial purchase defaults on the ingredient row.
	query := `SELECT i.id, i.name, COALESCE(i.description,''), COALESCE(i.image_path,''), i.unit_id,
	                 i.current_stock, i.current_cost_per_unit,
	                 i.low_stock_threshold, i.price_alert_percentage,
	                 i.category_id, i.is_active, i.created_at, i.updated_at,
	                 u.id, u.name, u.abbreviation, u.unit_type,
	                 COALESCE(c.name, ''),
	                 ph.last_price_at,
	                 COALESCE(bi.raw_quantity, i.purchase_qty)             AS bulk_qty,
	                 COALESCE(bi.raw_unit, pu.abbreviation, '')            AS bulk_unit,
	                 COALESCE(bi.raw_total_price, i.purchase_price)        AS bulk_total
	          FROM ingredients i
	          JOIN units u ON u.id = i.unit_id
	          LEFT JOIN ingredient_categories c ON c.id = i.category_id
	          LEFT JOIN units pu ON pu.id = i.purchase_unit_id
	          LEFT JOIN (
	              SELECT ingredient_id, MAX(recorded_at) AS last_price_at
	              FROM ingredient_price_history
	              GROUP BY ingredient_id
	          ) ph ON ph.ingredient_id = i.id
	          LEFT JOIN LATERAL (
	              SELECT raw_quantity, raw_unit, raw_total_price
	              FROM vendor_bill_items
	              WHERE ingredient_id = i.id
	                AND mapping_status IN ('auto_mapped', 'manually_mapped')
	                AND raw_quantity IS NOT NULL
	                AND raw_total_price IS NOT NULL
	              ORDER BY mapped_at DESC NULLS LAST, created_at DESC
	              LIMIT 1
	          ) bi ON true
	          WHERE i.is_active = true`
	var args []any
	argN := 1

	if search != "" {
		query += fmt.Sprintf(` AND i.name ILIKE '%%' || $%d || '%%'`, argN)
		args = append(args, search)
		argN++
	}
	if categoryID != nil {
		query += fmt.Sprintf(` AND i.category_id = $%d`, argN)
		args = append(args, *categoryID)
		argN++
	}
	if stockFilter == "low" {
		query += ` AND i.low_stock_threshold IS NOT NULL AND i.current_stock < i.low_stock_threshold`
	}

	switch sortBy {
	case "cost_asc":
		query += ` ORDER BY i.current_cost_per_unit ASC`
	case "cost_desc":
		query += ` ORDER BY i.current_cost_per_unit DESC`
	case "stock_asc":
		query += ` ORDER BY i.current_stock ASC`
	case "stock_desc":
		query += ` ORDER BY i.current_stock DESC`
	default:
		query += ` ORDER BY i.name`
	}

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.Ingredient
	for rows.Next() {
		var ing model.Ingredient
		var unit model.Unit
		var catName string
		if err := rows.Scan(
			&ing.ID, &ing.Name, &ing.Description, &ing.ImagePath, &ing.UnitID,
			&ing.CurrentStock, &ing.CurrentCostPerUnit,
			&ing.LowStockThreshold, &ing.PriceAlertPercentage,
			&ing.CategoryID, &ing.IsActive, &ing.CreatedAt, &ing.UpdatedAt,
			&unit.ID, &unit.Name, &unit.Abbreviation, &unit.UnitType,
			&catName,
			&ing.LastPriceAt,
			&ing.BulkQty, &ing.BulkUnitAbbr, &ing.BulkTotal,
		); err != nil {
			return nil, err
		}
		ing.Unit = &unit
		if ing.CategoryID != nil {
			ing.Category = &model.IngredientCategory{ID: *ing.CategoryID, Name: catName}
		}
		items = append(items, ing)
	}
	return items, rows.Err()
}

func (r *IngredientRepo) ListCategories(ctx context.Context) ([]model.IngredientCategory, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, name, sort_order, is_active, created_at
		 FROM ingredient_categories
		 WHERE is_active = true
		 ORDER BY sort_order, name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var cats []model.IngredientCategory
	for rows.Next() {
		var c model.IngredientCategory
		if err := rows.Scan(&c.ID, &c.Name, &c.SortOrder, &c.IsActive, &c.CreatedAt); err != nil {
			return nil, err
		}
		cats = append(cats, c)
	}
	return cats, rows.Err()
}

// GetIngredientCountsByCategory returns a map of category_id -> active ingredient count.
func (r *IngredientRepo) GetIngredientCountsByCategory(ctx context.Context) (map[uuid.UUID]int, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT category_id, COUNT(*) FROM ingredients
		 WHERE is_active = true AND category_id IS NOT NULL
		 GROUP BY category_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[uuid.UUID]int)
	for rows.Next() {
		var catID uuid.UUID
		var count int
		if err := rows.Scan(&catID, &count); err != nil {
			return nil, err
		}
		counts[catID] = count
	}
	return counts, rows.Err()
}

func (r *IngredientRepo) CreateCategory(ctx context.Context, name string, sortOrder int) (*model.IngredientCategory, error) {
	c := &model.IngredientCategory{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO ingredient_categories (name, sort_order) VALUES ($1, $2)
		 RETURNING id, name, sort_order, is_active, created_at`,
		name, sortOrder,
	).Scan(&c.ID, &c.Name, &c.SortOrder, &c.IsActive, &c.CreatedAt)
	return c, err
}

func (r *IngredientRepo) UpdateCategoryName(ctx context.Context, id uuid.UUID, name string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE ingredient_categories SET name = $1 WHERE id = $2`,
		name, id,
	)
	return err
}

// NextCategorySortOrder returns MAX(sort_order)+1 for new categories, so new
// entries land at the end of the list without the user specifying an order.
func (r *IngredientRepo) NextCategorySortOrder(ctx context.Context) (int, error) {
	var next int
	err := r.pool.QueryRow(ctx,
		`SELECT COALESCE(MAX(sort_order), -1) + 1 FROM ingredient_categories`,
	).Scan(&next)
	return next, err
}

func (r *IngredientRepo) DeleteCategory(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE ingredient_categories SET is_active = false WHERE id = $1`, id)
	return err
}

func (r *IngredientRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Ingredient, error) {
	ing := &model.Ingredient{}
	var unit model.Unit
	var catName string
	err := r.pool.QueryRow(ctx,
		`SELECT i.id, i.name, COALESCE(i.description,''), COALESCE(i.image_path,''), i.unit_id,
		        i.current_stock, i.current_cost_per_unit,
		        i.low_stock_threshold, i.price_alert_percentage,
		        i.category_id, i.is_active, i.created_at, i.updated_at,
		        i.purchase_qty, i.purchase_unit_id, i.purchase_price,
		        u.id, u.name, u.abbreviation, u.unit_type,
		        COALESCE(c.name, '')
		 FROM ingredients i
		 JOIN units u ON u.id = i.unit_id
		 LEFT JOIN ingredient_categories c ON c.id = i.category_id
		 WHERE i.id = $1`, id,
	).Scan(
		&ing.ID, &ing.Name, &ing.Description, &ing.ImagePath, &ing.UnitID,
		&ing.CurrentStock, &ing.CurrentCostPerUnit,
		&ing.LowStockThreshold, &ing.PriceAlertPercentage,
		&ing.CategoryID, &ing.IsActive, &ing.CreatedAt, &ing.UpdatedAt,
		&ing.PurchaseQty, &ing.PurchaseUnitID, &ing.PurchasePrice,
		&unit.ID, &unit.Name, &unit.Abbreviation, &unit.UnitType,
		&catName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	ing.Unit = &unit
	if ing.CategoryID != nil {
		ing.Category = &model.IngredientCategory{ID: *ing.CategoryID, Name: catName}
	}
	return ing, nil
}

type CreateIngredientParams struct {
	Name                 string
	Description          string
	ImagePath            string
	UnitID               uuid.UUID
	CurrentStock         float64
	CurrentCostPerUnit   float64
	LowStockThreshold    *float64
	PriceAlertPercentage float64
	CategoryID           *uuid.UUID
	PurchaseQty          *float64
	PurchaseUnitID       *uuid.UUID
	PurchasePrice        *float64
}

func (r *IngredientRepo) Create(ctx context.Context, p CreateIngredientParams) (*model.Ingredient, error) {
	var id uuid.UUID
	err := r.pool.QueryRow(ctx,
		`INSERT INTO ingredients (name, description, image_path, unit_id, current_stock, current_cost_per_unit,
		                          low_stock_threshold, price_alert_percentage, category_id,
		                          purchase_qty, purchase_unit_id, purchase_price)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		 RETURNING id`,
		p.Name, p.Description, p.ImagePath, p.UnitID, p.CurrentStock, p.CurrentCostPerUnit,
		p.LowStockThreshold, p.PriceAlertPercentage, p.CategoryID,
		p.PurchaseQty, p.PurchaseUnitID, p.PurchasePrice,
	).Scan(&id)
	if err != nil {
		return nil, err
	}
	return r.GetByID(ctx, id)
}

func (r *IngredientRepo) Update(ctx context.Context, id uuid.UUID, p CreateIngredientParams) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE ingredients SET name=$1, description=$2, image_path=$3, unit_id=$4,
		 low_stock_threshold=$5, price_alert_percentage=$6, category_id=$7,
		 purchase_qty=COALESCE($8, purchase_qty),
		 purchase_unit_id=COALESCE($9, purchase_unit_id),
		 purchase_price=COALESCE($10, purchase_price),
		 updated_at=NOW()
		 WHERE id=$11`,
		p.Name, p.Description, p.ImagePath, p.UnitID, p.LowStockThreshold, p.PriceAlertPercentage, p.CategoryID,
		p.PurchaseQty, p.PurchaseUnitID, p.PurchasePrice,
		id,
	)
	return err
}

func (r *IngredientRepo) UpdateStock(ctx context.Context, id uuid.UUID, quantity float64) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE ingredients SET current_stock = current_stock + $1, updated_at = NOW() WHERE id = $2`,
		quantity, id,
	)
	return err
}

func (r *IngredientRepo) UpdatePrice(ctx context.Context, id uuid.UUID, newPrice float64) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE ingredients SET current_cost_per_unit = $1, updated_at = NOW() WHERE id = $2`,
		newPrice, id,
	)
	return err
}

func (r *IngredientRepo) RecordPriceChange(ctx context.Context, ingredientID uuid.UUID, oldPrice, newPrice float64, source string, billID *uuid.UUID) error {
	changePct := float64(0)
	if oldPrice > 0 {
		changePct = ((newPrice - oldPrice) / oldPrice) * 100
	}
	_, err := r.pool.Exec(ctx,
		`INSERT INTO ingredient_price_history (ingredient_id, old_cost_per_unit, new_cost_per_unit, change_percentage, source, bill_id)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		ingredientID, oldPrice, newPrice, changePct, source, billID,
	)
	return err
}

func (r *IngredientRepo) GetPriceHistory(ctx context.Context, ingredientID uuid.UUID) ([]model.IngredientPriceHistory, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, ingredient_id, old_cost_per_unit, new_cost_per_unit, change_percentage, source, bill_id, recorded_at
		 FROM ingredient_price_history
		 WHERE ingredient_id = $1
		 ORDER BY recorded_at DESC
		 LIMIT 50`,
		ingredientID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var history []model.IngredientPriceHistory
	for rows.Next() {
		var h model.IngredientPriceHistory
		if err := rows.Scan(&h.ID, &h.IngredientID, &h.OldCostPerUnit, &h.NewCostPerUnit, &h.ChangePercentage, &h.Source, &h.BillID, &h.RecordedAt); err != nil {
			return nil, err
		}
		history = append(history, h)
	}
	return history, rows.Err()
}

func (r *IngredientRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `UPDATE ingredients SET is_active = false, updated_at = NOW() WHERE id = $1`, id)
	return err
}

// GetUnreadAlertsByIngredient returns a map of ingredient_id -> unread alert count.
func (r *IngredientRepo) GetUnreadAlertsByIngredient(ctx context.Context) (map[uuid.UUID]int, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT ingredient_id, COUNT(*) FROM alerts WHERE is_read = false GROUP BY ingredient_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[uuid.UUID]int)
	for rows.Next() {
		var ingID uuid.UUID
		var count int
		if err := rows.Scan(&ingID, &count); err != nil {
			return nil, err
		}
		counts[ingID] = count
	}
	return counts, rows.Err()
}

// GetRecipeCountsByIngredient returns a map of ingredient_id -> recipe count.
func (r *IngredientRepo) GetRecipeCountsByIngredient(ctx context.Context) (map[uuid.UUID]int, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT ri.ingredient_id, COUNT(DISTINCT ri.menu_item_id) as recipe_count
		 FROM recipe_ingredients ri
		 JOIN menu_items m ON m.id = ri.menu_item_id AND m.status != 'deleted'
		 GROUP BY ri.ingredient_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[uuid.UUID]int)
	for rows.Next() {
		var ingID uuid.UUID
		var count int
		if err := rows.Scan(&ingID, &count); err != nil {
			return nil, err
		}
		counts[ingID] = count
	}
	return counts, rows.Err()
}

// GetRecipesForIngredient returns recipe names that use a given ingredient.
func (r *IngredientRepo) GetRecipesForIngredient(ctx context.Context, ingredientID uuid.UUID) ([]model.MenuItem, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT m.id, m.name
		 FROM menu_items m
		 JOIN recipe_ingredients ri ON ri.menu_item_id = m.id
		 WHERE ri.ingredient_id = $1 AND m.status != 'deleted'
		 ORDER BY m.name`, ingredientID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.MenuItem
	for rows.Next() {
		var m model.MenuItem
		if err := rows.Scan(&m.ID, &m.Name); err != nil {
			return nil, err
		}
		items = append(items, m)
	}
	return items, rows.Err()
}

func (r *IngredientRepo) GetUnitByID(ctx context.Context, id uuid.UUID) (*model.Unit, error) {
	u := &model.Unit{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, abbreviation, unit_type, base_unit_id, conversion_factor, created_at
		 FROM units WHERE id = $1`, id,
	).Scan(&u.ID, &u.Name, &u.Abbreviation, &u.UnitType, &u.BaseUnitID, &u.ConversionFactor, &u.CreatedAt)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func (r *IngredientRepo) ListUnits(ctx context.Context) ([]model.Unit, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, name, abbreviation, unit_type, base_unit_id, conversion_factor, created_at
		 FROM units ORDER BY unit_type, name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var units []model.Unit
	for rows.Next() {
		var u model.Unit
		if err := rows.Scan(&u.ID, &u.Name, &u.Abbreviation, &u.UnitType, &u.BaseUnitID, &u.ConversionFactor, &u.CreatedAt); err != nil {
			return nil, err
		}
		units = append(units, u)
	}
	return units, rows.Err()
}

// GetLowStockIngredients returns ingredients where current_stock < low_stock_threshold.
func (r *IngredientRepo) GetLowStockIngredients(ctx context.Context) ([]model.Ingredient, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT i.id, i.name, COALESCE(i.description,''), COALESCE(i.image_path,''), i.unit_id,
		        i.current_stock, i.current_cost_per_unit,
		        i.low_stock_threshold, i.price_alert_percentage,
		        i.category_id, i.is_active, i.created_at, i.updated_at,
		        u.id, u.name, u.abbreviation, u.unit_type,
		        COALESCE(c.name, '')
		 FROM ingredients i
		 JOIN units u ON u.id = i.unit_id
		 LEFT JOIN ingredient_categories c ON c.id = i.category_id
		 WHERE i.is_active = true
		   AND i.low_stock_threshold IS NOT NULL
		   AND i.current_stock < i.low_stock_threshold
		 ORDER BY i.current_stock / i.low_stock_threshold ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.Ingredient
	for rows.Next() {
		var ing model.Ingredient
		var unit model.Unit
		var catName string
		if err := rows.Scan(
			&ing.ID, &ing.Name, &ing.Description, &ing.ImagePath, &ing.UnitID,
			&ing.CurrentStock, &ing.CurrentCostPerUnit,
			&ing.LowStockThreshold, &ing.PriceAlertPercentage,
			&ing.CategoryID, &ing.IsActive, &ing.CreatedAt, &ing.UpdatedAt,
			&unit.ID, &unit.Name, &unit.Abbreviation, &unit.UnitType,
			&catName,
		); err != nil {
			return nil, err
		}
		ing.Unit = &unit
		if ing.CategoryID != nil {
			ing.Category = &model.IngredientCategory{ID: *ing.CategoryID, Name: catName}
		}
		items = append(items, ing)
	}
	return items, rows.Err()
}

