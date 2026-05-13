package repository

import (
	"context"
	"errors"
	"fmt"

	"searlo-cafe/internal/model"
	"searlo-cafe/internal/units"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type RecipeRepo struct {
	pool *pgxpool.Pool
}

func NewRecipeRepo(pool *pgxpool.Pool) *RecipeRepo {
	return &RecipeRepo{pool: pool}
}

// Categories

func (r *RecipeRepo) ListCategories(ctx context.Context) ([]model.MenuCategory, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, name, sort_order, is_active, created_at FROM menu_categories WHERE is_active = true ORDER BY sort_order, name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cats []model.MenuCategory
	for rows.Next() {
		var c model.MenuCategory
		if err := rows.Scan(&c.ID, &c.Name, &c.SortOrder, &c.IsActive, &c.CreatedAt); err != nil {
			return nil, err
		}
		cats = append(cats, c)
	}
	return cats, rows.Err()
}

func (r *RecipeRepo) CreateCategory(ctx context.Context, name string, sortOrder int) (*model.MenuCategory, error) {
	c := &model.MenuCategory{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO menu_categories (name, sort_order) VALUES ($1, $2)
		 RETURNING id, name, sort_order, is_active, created_at`,
		name, sortOrder,
	).Scan(&c.ID, &c.Name, &c.SortOrder, &c.IsActive, &c.CreatedAt)
	return c, err
}

// Recipes (menu_items table)

func (r *RecipeRepo) ListRecipes(ctx context.Context, search, category, status, sortBy string, ingredientIDs []uuid.UUID) ([]model.MenuItem, error) {
	query := `SELECT m.id, m.category_id, m.name, COALESCE(m.description,''), COALESCE(m.image_path,''),
	                 m.selling_price, m.status, COALESCE(m.preparation_notes,''), m.allergens,
	                 m.yield, m.yield_unit,
	                 m.created_at, m.updated_at,
	                 COALESCE(c.name, '')
	          FROM menu_items m
	          LEFT JOIN menu_categories c ON c.id = m.category_id
	          WHERE m.status != 'deleted'`
	var args []any
	argN := 1

	if search != "" {
		query += fmt.Sprintf(` AND m.name ILIKE '%%' || $%d || '%%'`, argN)
		args = append(args, search)
		argN++
	}
	if category != "" {
		query += fmt.Sprintf(` AND c.name = $%d`, argN)
		args = append(args, category)
		argN++
	}
	if status != "" {
		query += fmt.Sprintf(` AND m.status = $%d`, argN)
		args = append(args, status)
		argN++
	}
	for _, ingID := range ingredientIDs {
		query += fmt.Sprintf(` AND m.id IN (SELECT menu_item_id FROM recipe_ingredients WHERE ingredient_id = $%d)`, argN)
		args = append(args, ingID)
		argN++
	}

	switch sortBy {
	case "price_asc":
		query += ` ORDER BY m.selling_price ASC`
	case "price_desc":
		query += ` ORDER BY m.selling_price DESC`
	case "name":
		query += ` ORDER BY m.name`
	default:
		query += ` ORDER BY c.sort_order, m.name`
	}

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.MenuItem
	for rows.Next() {
		var m model.MenuItem
		var catName string
		if err := rows.Scan(&m.ID, &m.CategoryID, &m.Name, &m.Description, &m.ImagePath,
			&m.SellingPrice, &m.Status, &m.PreparationNotes, &m.Allergens,
			&m.Yield, &m.YieldUnit,
			&m.CreatedAt, &m.UpdatedAt, &catName); err != nil {
			return nil, err
		}
		if m.CategoryID != nil {
			m.Category = &model.MenuCategory{Name: catName}
		}
		items = append(items, m)
	}
	return items, rows.Err()
}

func (r *RecipeRepo) GetRecipeByID(ctx context.Context, id uuid.UUID) (*model.MenuItem, error) {
	m := &model.MenuItem{}
	var catName string
	err := r.pool.QueryRow(ctx,
		`SELECT m.id, m.category_id, m.name, COALESCE(m.description,''), COALESCE(m.image_path,''),
		        m.selling_price, m.status, COALESCE(m.preparation_notes,''), m.allergens,
		        m.yield, m.yield_unit,
		        m.created_at, m.updated_at,
		        COALESCE(c.name, '')
		 FROM menu_items m
		 LEFT JOIN menu_categories c ON c.id = m.category_id
		 WHERE m.id = $1`, id,
	).Scan(&m.ID, &m.CategoryID, &m.Name, &m.Description, &m.ImagePath,
		&m.SellingPrice, &m.Status, &m.PreparationNotes, &m.Allergens,
		&m.Yield, &m.YieldUnit,
		&m.CreatedAt, &m.UpdatedAt, &catName)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if m.CategoryID != nil {
		m.Category = &model.MenuCategory{Name: catName}
	}
	return m, nil
}

type CreateRecipeParams struct {
	CategoryID       *uuid.UUID
	Name             string
	Description      string
	ImagePath        string
	SellingPrice     float64
	Status           string
	PreparationNotes string
	Allergens        []string
	Yield            int
	YieldUnit        string
}

func (r *RecipeRepo) CreateRecipe(ctx context.Context, p CreateRecipeParams) (*model.MenuItem, error) {
	m := &model.MenuItem{}
	status := p.Status
	if status == "" {
		status = "draft"
	}
	if p.Yield < 1 {
		p.Yield = 1
	}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO menu_items (category_id, name, description, image_path, selling_price, status, preparation_notes, allergens, yield, yield_unit)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		 RETURNING id, category_id, name, COALESCE(description,''), COALESCE(image_path,''),
		           selling_price, status, COALESCE(preparation_notes,''), allergens, yield, yield_unit, created_at, updated_at`,
		p.CategoryID, p.Name, p.Description, p.ImagePath, p.SellingPrice, status, p.PreparationNotes, p.Allergens, p.Yield, p.YieldUnit,
	).Scan(&m.ID, &m.CategoryID, &m.Name, &m.Description, &m.ImagePath,
		&m.SellingPrice, &m.Status, &m.PreparationNotes, &m.Allergens, &m.Yield, &m.YieldUnit, &m.CreatedAt, &m.UpdatedAt)
	return m, err
}

func (r *RecipeRepo) UpdateRecipe(ctx context.Context, id uuid.UUID, p CreateRecipeParams) error {
	if p.Yield < 1 {
		p.Yield = 1
	}
	_, err := r.pool.Exec(ctx,
		`UPDATE menu_items SET category_id=$1, name=$2, description=$3, image_path=$4, selling_price=$5,
		 status=$6, preparation_notes=$7, allergens=$8, yield=$9, yield_unit=$10, updated_at=NOW() WHERE id=$11`,
		p.CategoryID, p.Name, p.Description, p.ImagePath, p.SellingPrice, p.Status, p.PreparationNotes, p.Allergens, p.Yield, p.YieldUnit, id,
	)
	return err
}

func (r *RecipeRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE menu_items SET status = $1, updated_at = NOW() WHERE id = $2`,
		status, id,
	)
	return err
}

func (r *RecipeRepo) UpdatePrepDetails(ctx context.Context, id uuid.UUID, notes string, allergens []string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE menu_items SET preparation_notes = $1, allergens = $2, updated_at = NOW() WHERE id = $3`,
		notes, allergens, id,
	)
	return err
}

func (r *RecipeRepo) DeleteRecipe(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `UPDATE menu_items SET status = 'deleted', updated_at = NOW() WHERE id = $1`, id)
	return err
}

// Recipe Ingredients

func (r *RecipeRepo) GetRecipeIngredients(ctx context.Context, menuItemID uuid.UUID) ([]model.RecipeIngredient, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT ri.id, ri.menu_item_id, ri.ingredient_id, ri.quantity, ri.ingredient_type, COALESCE(ri.notes,''), ri.display_unit_id,
		        i.name, i.current_cost_per_unit, COALESCE(i.image_path,''),
		        bu.id, bu.name, bu.abbreviation, bu.unit_type, bu.conversion_factor,
		        du.id, du.name, du.abbreviation, du.unit_type, du.conversion_factor
		 FROM recipe_ingredients ri
		 JOIN ingredients i ON i.id = ri.ingredient_id
		 JOIN units bu ON bu.id = i.unit_id
		 LEFT JOIN units du ON du.id = ri.display_unit_id
		 WHERE ri.menu_item_id = $1
		 ORDER BY ri.ingredient_type, i.name`, menuItemID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.RecipeIngredient
	for rows.Next() {
		var ri model.RecipeIngredient
		var ingName string
		var costPerUnit float64
		var imagePath string
		var baseUnit model.Unit
		var duID *uuid.UUID
		var duName, duAbbr, duType *string
		var duFactor *float64
		if err := rows.Scan(&ri.ID, &ri.MenuItemID, &ri.IngredientID, &ri.Quantity, &ri.IngredientType, &ri.Notes, &ri.DisplayUnitID,
			&ingName, &costPerUnit, &imagePath,
			&baseUnit.ID, &baseUnit.Name, &baseUnit.Abbreviation, &baseUnit.UnitType, &baseUnit.ConversionFactor,
			&duID, &duName, &duAbbr, &duType, &duFactor); err != nil {
			return nil, err
		}
		ri.Ingredient = &model.Ingredient{Name: ingName, CurrentCostPerUnit: costPerUnit, ImagePath: imagePath, UnitID: baseUnit.ID}
		ri.Ingredient.Unit = &baseUnit
		ri.LineCost = ri.Quantity * costPerUnit

		if duID != nil {
			displayUnit := &model.Unit{ID: *duID, Name: *duName, Abbreviation: *duAbbr, UnitType: *duType, ConversionFactor: duFactor}
			ri.DisplayUnit = displayUnit
			qty, err := units.ConvertQuantity(ri.Quantity, &baseUnit, displayUnit)
			if err == nil {
				ri.DisplayQuantity = qty
			} else {
				ri.DisplayQuantity = ri.Quantity
			}
		} else {
			ri.DisplayUnit = &baseUnit
			ri.DisplayQuantity = ri.Quantity
		}
		items = append(items, ri)
	}
	return items, rows.Err()
}

func (r *RecipeRepo) AddRecipeIngredient(ctx context.Context, menuItemID, ingredientID uuid.UUID, qty float64, ingType, notes string, displayUnitID *uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO recipe_ingredients (menu_item_id, ingredient_id, quantity, ingredient_type, notes, display_unit_id)
		 VALUES ($1, $2, $3, $4, $5, $6)
		 ON CONFLICT (menu_item_id, ingredient_id) DO UPDATE SET quantity = $3, ingredient_type = $4, notes = $5, display_unit_id = $6`,
		menuItemID, ingredientID, qty, ingType, notes, displayUnitID,
	)
	return err
}

func (r *RecipeRepo) GetRecipeIngredientByID(ctx context.Context, id uuid.UUID) (*model.RecipeIngredient, error) {
	var ri model.RecipeIngredient
	var baseUnit model.Unit
	var ingName string
	err := r.pool.QueryRow(ctx,
		`SELECT ri.id, ri.menu_item_id, ri.ingredient_id, ri.quantity, ri.ingredient_type,
		        i.name,
		        bu.id, bu.name, bu.abbreviation, bu.unit_type, bu.conversion_factor
		 FROM recipe_ingredients ri
		 JOIN ingredients i ON i.id = ri.ingredient_id
		 JOIN units bu ON bu.id = i.unit_id
		 WHERE ri.id = $1`, id,
	).Scan(&ri.ID, &ri.MenuItemID, &ri.IngredientID, &ri.Quantity, &ri.IngredientType,
		&ingName,
		&baseUnit.ID, &baseUnit.Name, &baseUnit.Abbreviation, &baseUnit.UnitType, &baseUnit.ConversionFactor)
	if err != nil {
		return nil, err
	}
	ri.Ingredient = &model.Ingredient{Name: ingName, UnitID: baseUnit.ID}
	ri.Ingredient.Unit = &baseUnit
	return &ri, nil
}

func (r *RecipeRepo) UpdateRecipeIngredient(ctx context.Context, id uuid.UUID, qty float64, ingType string, displayUnitID *uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE recipe_ingredients SET quantity = $2, ingredient_type = $3, display_unit_id = $4 WHERE id = $1`,
		id, qty, ingType, displayUnitID,
	)
	return err
}

func (r *RecipeRepo) RemoveRecipeIngredient(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM recipe_ingredients WHERE id = $1`, id)
	return err
}

// Utility Costs (shared via junction + per-recipe extras)

// GetUtilityCosts returns the combined view of utility costs for a recipe:
// shared tenant-level costs linked through recipe_utility_costs UNION
// recipe-specific extras from recipe_utility_cost_extras. The returned
// RecipeUtilityCost.ID refers to the utility_cost row for shared entries
// and to the extras row for per-recipe entries — distinguished by Source.
func (r *RecipeRepo) GetUtilityCosts(ctx context.Context, menuItemID uuid.UUID) ([]model.RecipeUtilityCost, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT u.id, u.name, u.cost, 'shared' AS source
		 FROM recipe_utility_costs ruc
		 JOIN utility_costs u ON u.id = ruc.utility_cost_id
		 WHERE ruc.menu_item_id = $1
		 UNION ALL
		 SELECT id, name, cost, 'extra' AS source
		 FROM recipe_utility_cost_extras
		 WHERE menu_item_id = $1
		 ORDER BY name`,
		menuItemID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var costs []model.RecipeUtilityCost
	for rows.Next() {
		var c model.RecipeUtilityCost
		if err := rows.Scan(&c.ID, &c.Name, &c.Cost, &c.Source); err != nil {
			return nil, err
		}
		costs = append(costs, c)
	}
	return costs, rows.Err()
}

// GetLinkedUtilityCostIDs returns the set of tenant-level utility_cost IDs
// currently linked to a recipe. Used to pre-check the picker checkboxes.
func (r *RecipeRepo) GetLinkedUtilityCostIDs(ctx context.Context, menuItemID uuid.UUID) (map[uuid.UUID]bool, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT utility_cost_id FROM recipe_utility_costs WHERE menu_item_id = $1`,
		menuItemID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	linked := make(map[uuid.UUID]bool)
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		linked[id] = true
	}
	return linked, rows.Err()
}

// LinkUtilityCost adds a (menu_item, utility_cost) junction row (idempotent).
func (r *RecipeRepo) LinkUtilityCost(ctx context.Context, menuItemID, utilityCostID uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO recipe_utility_costs (menu_item_id, utility_cost_id)
		 VALUES ($1, $2) ON CONFLICT DO NOTHING`,
		menuItemID, utilityCostID,
	)
	return err
}

// UnlinkUtilityCost removes a junction row (idempotent).
func (r *RecipeRepo) UnlinkUtilityCost(ctx context.Context, menuItemID, utilityCostID uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`DELETE FROM recipe_utility_costs WHERE menu_item_id = $1 AND utility_cost_id = $2`,
		menuItemID, utilityCostID,
	)
	return err
}

// Per-recipe extras

func (r *RecipeRepo) GetUtilityExtras(ctx context.Context, menuItemID uuid.UUID) ([]model.RecipeUtilityExtra, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, menu_item_id, name, cost, created_at
		 FROM recipe_utility_cost_extras
		 WHERE menu_item_id = $1
		 ORDER BY name`,
		menuItemID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []model.RecipeUtilityExtra
	for rows.Next() {
		var e model.RecipeUtilityExtra
		if err := rows.Scan(&e.ID, &e.MenuItemID, &e.Name, &e.Cost, &e.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

func (r *RecipeRepo) AddUtilityExtra(ctx context.Context, menuItemID uuid.UUID, name string, cost float64) (*model.RecipeUtilityExtra, error) {
	var e model.RecipeUtilityExtra
	err := r.pool.QueryRow(ctx,
		`INSERT INTO recipe_utility_cost_extras (menu_item_id, name, cost)
		 VALUES ($1, $2, $3)
		 ON CONFLICT (menu_item_id, name) DO UPDATE SET cost = EXCLUDED.cost
		 RETURNING id, menu_item_id, name, cost, created_at`,
		menuItemID, name, cost,
	).Scan(&e.ID, &e.MenuItemID, &e.Name, &e.Cost, &e.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &e, nil
}

func (r *RecipeRepo) RemoveUtilityExtra(ctx context.Context, id uuid.UUID) (menuItemID uuid.UUID, name string, err error) {
	err = r.pool.QueryRow(ctx,
		`DELETE FROM recipe_utility_cost_extras WHERE id = $1
		 RETURNING menu_item_id, name`,
		id,
	).Scan(&menuItemID, &name)
	return menuItemID, name, err
}

func (r *RecipeRepo) GetUtilityCostNameByID(ctx context.Context, id uuid.UUID) (string, error) {
	var name string
	err := r.pool.QueryRow(ctx, `SELECT name FROM utility_costs WHERE id = $1`, id).Scan(&name)
	return name, err
}

// Recipe cost snapshots

// SnapshotRecipe recomputes the current cost for a recipe and inserts one row
// into recipe_cost_snapshots. If the newly computed total matches the latest
// snapshot AND reason has no distinct signal, the insert is skipped to avoid
// noise from no-op resaves.
func (r *RecipeRepo) SnapshotRecipe(ctx context.Context, menuItemID uuid.UUID, reason string) error {
	var ingCost, utilCost float64

	if err := r.pool.QueryRow(ctx,
		`SELECT COALESCE(SUM(ri.quantity * i.current_cost_per_unit), 0)
		 FROM recipe_ingredients ri
		 JOIN ingredients i ON i.id = ri.ingredient_id
		 WHERE ri.menu_item_id = $1`,
		menuItemID,
	).Scan(&ingCost); err != nil {
		return err
	}

	if err := r.pool.QueryRow(ctx,
		`SELECT COALESCE((SELECT SUM(u.cost)
		                  FROM recipe_utility_costs ruc
		                  JOIN utility_costs u ON u.id = ruc.utility_cost_id
		                  WHERE ruc.menu_item_id = $1), 0)
		      + COALESCE((SELECT SUM(cost)
		                  FROM recipe_utility_cost_extras
		                  WHERE menu_item_id = $1), 0)`,
		menuItemID,
	).Scan(&utilCost); err != nil {
		return err
	}

	total := ingCost + utilCost

	// De-dup: skip if last snapshot has identical total AND reason.
	var lastTotal float64
	var lastReason string
	err := r.pool.QueryRow(ctx,
		`SELECT total_cost, reason FROM recipe_cost_snapshots
		 WHERE menu_item_id = $1
		 ORDER BY snapshot_at DESC LIMIT 1`,
		menuItemID,
	).Scan(&lastTotal, &lastReason)
	if err == nil && lastTotal == total && lastReason == reason {
		return nil
	}

	_, err = r.pool.Exec(ctx,
		`INSERT INTO recipe_cost_snapshots
		   (menu_item_id, total_cost, ingredient_cost, utility_cost, yield_at_snapshot, reason)
		 VALUES ($1, $2, $3, $4,
		         (SELECT yield FROM menu_items WHERE id = $1), $5)`,
		menuItemID, total, ingCost, utilCost, reason,
	)
	return err
}

// SnapshotRecipesUsingIngredient records a snapshot for every recipe that uses
// the given ingredient. Called after an ingredient price update.
func (r *RecipeRepo) SnapshotRecipesUsingIngredient(ctx context.Context, ingredientID uuid.UUID, reason string) error {
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT menu_item_id FROM recipe_ingredients WHERE ingredient_id = $1`,
		ingredientID,
	)
	if err != nil {
		return err
	}
	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return err
		}
		ids = append(ids, id)
	}
	rows.Close()

	for _, id := range ids {
		if err := r.SnapshotRecipe(ctx, id, reason); err != nil {
			return err
		}
	}
	return nil
}

// SnapshotRecipesUsingUtilityCost records a snapshot for every recipe linked
// to a utility cost. Called after a utility cost price update.
func (r *RecipeRepo) SnapshotRecipesUsingUtilityCost(ctx context.Context, utilityCostID uuid.UUID, reason string) error {
	rows, err := r.pool.Query(ctx,
		`SELECT menu_item_id FROM recipe_utility_costs WHERE utility_cost_id = $1`,
		utilityCostID,
	)
	if err != nil {
		return err
	}
	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return err
		}
		ids = append(ids, id)
	}
	rows.Close()

	for _, id := range ids {
		if err := r.SnapshotRecipe(ctx, id, reason); err != nil {
			return err
		}
	}
	return nil
}

// GetRecipeCostHistory returns snapshots for a recipe, newest first.
func (r *RecipeRepo) GetRecipeCostHistory(ctx context.Context, menuItemID uuid.UUID, limit int) ([]model.RecipeCostSnapshot, error) {
	if limit <= 0 {
		limit = 100
	}
	rows, err := r.pool.Query(ctx,
		`SELECT id, menu_item_id, total_cost, ingredient_cost, utility_cost, yield_at_snapshot, reason, snapshot_at
		 FROM recipe_cost_snapshots
		 WHERE menu_item_id = $1
		 ORDER BY snapshot_at DESC
		 LIMIT $2`,
		menuItemID, limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []model.RecipeCostSnapshot
	for rows.Next() {
		var s model.RecipeCostSnapshot
		if err := rows.Scan(&s.ID, &s.MenuItemID, &s.TotalCost, &s.IngredientCost, &s.UtilityCost, &s.YieldAtSnapshot, &s.Reason, &s.SnapshotAt); err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}

// GetUnreadAlertCount returns count of unread alerts.
func (r *RecipeRepo) GetUnreadAlertCount(ctx context.Context) (int, error) {
	var count int
	err := r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM alerts WHERE is_read = false`).Scan(&count)
	return count, err
}
