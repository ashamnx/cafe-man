package repository

import (
	"context"
	"encoding/json"
	"fmt"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type StockRepo struct {
	pool *pgxpool.Pool
}

func NewStockRepo(pool *pgxpool.Pool) *StockRepo {
	return &StockRepo{pool: pool}
}

// ---------------------------------------------------------------------------
// Sale entries
// ---------------------------------------------------------------------------

func (r *StockRepo) CreateSaleEntry(ctx context.Context, saleDate string, notes string, createdBy uuid.UUID) (*model.SaleEntry, error) {
	entry := &model.SaleEntry{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO sale_entries (sale_date, notes, created_by)
		 VALUES ($1, $2, $3)
		 RETURNING id, sale_date, COALESCE(notes,''), status, created_by, created_at, updated_at`,
		saleDate, notes, createdBy,
	).Scan(&entry.ID, &entry.SaleDate, &entry.Notes, &entry.Status, &entry.CreatedBy, &entry.CreatedAt, &entry.UpdatedAt)
	return entry, err
}

func (r *StockRepo) GetSaleEntryByID(ctx context.Context, id uuid.UUID) (*model.SaleEntry, error) {
	entry := &model.SaleEntry{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, sale_date, COALESCE(notes,''), status, created_by, created_at, updated_at
		 FROM sale_entries WHERE id = $1`, id,
	).Scan(&entry.ID, &entry.SaleDate, &entry.Notes, &entry.Status, &entry.CreatedBy, &entry.CreatedAt, &entry.UpdatedAt)
	if err != nil {
		return nil, err
	}

	// Load items.
	items, err := r.GetSaleEntryItems(ctx, id)
	if err != nil {
		return nil, err
	}
	entry.Items = items

	// Compute aggregates.
	for _, item := range items {
		entry.TotalItems += item.Quantity
		entry.TotalValue += item.SellingPrice * float64(item.Quantity)
	}
	return entry, nil
}

func (r *StockRepo) ListSaleEntries(ctx context.Context) ([]model.SaleEntry, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT se.id, se.sale_date, COALESCE(se.notes,''), se.status, se.created_by, se.created_at, se.updated_at,
		        COALESCE(SUM(sei.quantity), 0), COALESCE(SUM(sei.quantity * sei.selling_price), 0)
		 FROM sale_entries se
		 LEFT JOIN sale_entry_items sei ON sei.sale_entry_id = se.id
		 GROUP BY se.id
		 ORDER BY se.sale_date DESC, se.created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []model.SaleEntry
	for rows.Next() {
		var e model.SaleEntry
		if err := rows.Scan(
			&e.ID, &e.SaleDate, &e.Notes, &e.Status, &e.CreatedBy, &e.CreatedAt, &e.UpdatedAt,
			&e.TotalItems, &e.TotalValue,
		); err != nil {
			return nil, err
		}
		entries = append(entries, e)
	}
	return entries, rows.Err()
}

func (r *StockRepo) GetSaleEntryItems(ctx context.Context, saleEntryID uuid.UUID) ([]model.SaleEntryItem, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT sei.id, sei.sale_entry_id, sei.menu_item_id, sei.quantity, sei.selling_price, sei.created_at,
		        mi.name
		 FROM sale_entry_items sei
		 JOIN menu_items mi ON mi.id = sei.menu_item_id
		 WHERE sei.sale_entry_id = $1
		 ORDER BY sei.created_at`, saleEntryID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.SaleEntryItem
	for rows.Next() {
		var item model.SaleEntryItem
		if err := rows.Scan(
			&item.ID, &item.SaleEntryID, &item.MenuItemID, &item.Quantity,
			&item.SellingPrice, &item.CreatedAt, &item.MenuItemName,
		); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *StockRepo) AddSaleEntryItem(ctx context.Context, saleEntryID, menuItemID uuid.UUID, quantity int, sellingPrice float64) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO sale_entry_items (sale_entry_id, menu_item_id, quantity, selling_price)
		 VALUES ($1, $2, $3, $4)`,
		saleEntryID, menuItemID, quantity, sellingPrice)
	return err
}

func (r *StockRepo) DeleteSaleEntryItem(ctx context.Context, itemID uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM sale_entry_items WHERE id = $1`, itemID)
	return err
}

func (r *StockRepo) DeleteSaleEntry(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM sale_entries WHERE id = $1 AND status = 'draft'`, id)
	return err
}

// ApplySaleEntry deducts ingredient stock based on recipe definitions.
// Uses a transaction to ensure all deductions succeed or fail together.
func (r *StockRepo) ApplySaleEntry(ctx context.Context, saleEntryID, userID uuid.UUID) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Verify still in draft.
	var status string
	err = tx.QueryRow(ctx, `SELECT status FROM sale_entries WHERE id = $1 FOR UPDATE`, saleEntryID).Scan(&status)
	if err != nil {
		return fmt.Errorf("get sale entry: %w", err)
	}
	if status != "draft" {
		return fmt.Errorf("sale entry already applied")
	}

	// Fetch items.
	rows, err := tx.Query(ctx,
		`SELECT sei.id, sei.menu_item_id, sei.quantity
		 FROM sale_entry_items sei WHERE sei.sale_entry_id = $1`, saleEntryID)
	if err != nil {
		return fmt.Errorf("get items: %w", err)
	}

	type saleItem struct {
		id         uuid.UUID
		menuItemID uuid.UUID
		quantity   int
	}
	var items []saleItem
	for rows.Next() {
		var si saleItem
		if err := rows.Scan(&si.id, &si.menuItemID, &si.quantity); err != nil {
			rows.Close()
			return err
		}
		items = append(items, si)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}

	if len(items) == 0 {
		return fmt.Errorf("no items to apply")
	}

	// For each sale item, look up recipe ingredients and deduct stock.
	for _, item := range items {
		recipeRows, err := tx.Query(ctx,
			`SELECT ri.ingredient_id, ri.quantity
			 FROM recipe_ingredients ri WHERE ri.menu_item_id = $1`, item.menuItemID)
		if err != nil {
			return fmt.Errorf("get recipe ingredients: %w", err)
		}

		type recipeIng struct {
			ingredientID uuid.UUID
			qtyPerUnit   float64
		}
		var recipeIngs []recipeIng
		for recipeRows.Next() {
			var ri recipeIng
			if err := recipeRows.Scan(&ri.ingredientID, &ri.qtyPerUnit); err != nil {
				recipeRows.Close()
				return err
			}
			recipeIngs = append(recipeIngs, ri)
		}
		recipeRows.Close()
		if err := recipeRows.Err(); err != nil {
			return err
		}

		for _, ri := range recipeIngs {
			totalDeduction := ri.qtyPerUnit * float64(item.quantity)

			// Snapshot the deduction.
			_, err := tx.Exec(ctx,
				`INSERT INTO sale_entry_deductions (sale_entry_id, sale_entry_item_id, ingredient_id, quantity_per_unit, total_quantity)
				 VALUES ($1, $2, $3, $4, $5)`,
				saleEntryID, item.id, ri.ingredientID, ri.qtyPerUnit, totalDeduction)
			if err != nil {
				return fmt.Errorf("insert deduction: %w", err)
			}

			// Deduct from stock.
			_, err = tx.Exec(ctx,
				`UPDATE ingredients SET current_stock = current_stock - $1, updated_at = NOW() WHERE id = $2`,
				totalDeduction, ri.ingredientID)
			if err != nil {
				return fmt.Errorf("update stock: %w", err)
			}

			// Record movement.
			_, err = tx.Exec(ctx,
				`INSERT INTO stock_movements (ingredient_id, quantity, movement_type, reference_type, reference_id, created_by)
				 VALUES ($1, $2, 'sale', 'sale_entry', $3, $4)`,
				ri.ingredientID, -totalDeduction, saleEntryID, userID)
			if err != nil {
				return fmt.Errorf("record movement: %w", err)
			}
		}
	}

	// Mark as applied.
	_, err = tx.Exec(ctx,
		`UPDATE sale_entries SET status = 'applied', updated_at = NOW() WHERE id = $1`, saleEntryID)
	if err != nil {
		return fmt.Errorf("update status: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}

	// Post-commit: check for low stock alerts (non-critical, outside tx).
	r.checkLowStockAlerts(ctx, saleEntryID)

	return nil
}

func (r *StockRepo) checkLowStockAlerts(ctx context.Context, saleEntryID uuid.UUID) {
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT d.ingredient_id, i.name, i.current_stock, i.low_stock_threshold
		 FROM sale_entry_deductions d
		 JOIN ingredients i ON i.id = d.ingredient_id
		 WHERE d.sale_entry_id = $1
		   AND i.low_stock_threshold IS NOT NULL
		   AND i.current_stock < i.low_stock_threshold`, saleEntryID)
	if err != nil {
		return
	}
	defer rows.Close()

	for rows.Next() {
		var ingID uuid.UUID
		var name string
		var stock, threshold float64
		if err := rows.Scan(&ingID, &name, &stock, &threshold); err != nil {
			continue
		}
		details, _ := json.Marshal(map[string]any{
			"current_stock": stock,
			"threshold":     threshold,
		})
		r.pool.Exec(ctx,
			`INSERT INTO alerts (alert_type, ingredient_id, message, details)
			 VALUES ('low_stock', $1, $2, $3)`,
			ingID,
			fmt.Sprintf("%s is low on stock (%.2f remaining, threshold: %.2f)", name, stock, threshold),
			details,
		)
	}
}

// GetSaleEntryDeductions returns the ingredient deductions for an applied sale entry.
func (r *StockRepo) GetSaleEntryDeductions(ctx context.Context, saleEntryID uuid.UUID) ([]model.SaleEntryDeduction, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT d.id, d.sale_entry_id, d.sale_entry_item_id, d.ingredient_id,
		        d.quantity_per_unit, d.total_quantity, d.created_at,
		        i.name, u.abbreviation
		 FROM sale_entry_deductions d
		 JOIN ingredients i ON i.id = d.ingredient_id
		 JOIN units u ON u.id = i.unit_id
		 WHERE d.sale_entry_id = $1
		 ORDER BY i.name`, saleEntryID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var deductions []model.SaleEntryDeduction
	for rows.Next() {
		var d model.SaleEntryDeduction
		if err := rows.Scan(
			&d.ID, &d.SaleEntryID, &d.SaleEntryItemID, &d.IngredientID,
			&d.QuantityPerUnit, &d.TotalQuantity, &d.CreatedAt,
			&d.IngredientName, &d.UnitAbbr,
		); err != nil {
			return nil, err
		}
		deductions = append(deductions, d)
	}
	return deductions, rows.Err()
}

// ---------------------------------------------------------------------------
// Wastage
// ---------------------------------------------------------------------------

func (r *StockRepo) CreateWastageRecord(ctx context.Context, ingredientID uuid.UUID, quantity float64, wastageType, wastageDate, notes string, createdBy uuid.UUID) (*model.WastageRecord, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Insert wastage record.
	rec := &model.WastageRecord{}
	err = tx.QueryRow(ctx,
		`INSERT INTO wastage_records (ingredient_id, quantity, wastage_type, wastage_date, notes, created_by)
		 VALUES ($1, $2, $3, $4, $5, $6)
		 RETURNING id, ingredient_id, quantity, wastage_type, wastage_date, COALESCE(notes,''), created_by, created_at`,
		ingredientID, quantity, wastageType, wastageDate, notes, createdBy,
	).Scan(&rec.ID, &rec.IngredientID, &rec.Quantity, &rec.WastageType, &rec.WastageDate, &rec.Notes, &rec.CreatedBy, &rec.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("insert wastage: %w", err)
	}

	// Deduct stock.
	_, err = tx.Exec(ctx,
		`UPDATE ingredients SET current_stock = current_stock - $1, updated_at = NOW() WHERE id = $2`,
		quantity, ingredientID)
	if err != nil {
		return nil, fmt.Errorf("update stock: %w", err)
	}

	// Record movement.
	_, err = tx.Exec(ctx,
		`INSERT INTO stock_movements (ingredient_id, quantity, movement_type, reference_type, reference_id, notes, created_by)
		 VALUES ($1, $2, 'wastage', 'wastage_record', $3, $4, $5)`,
		ingredientID, -quantity, rec.ID, notes, createdBy)
	if err != nil {
		return nil, fmt.Errorf("record movement: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, fmt.Errorf("commit: %w", err)
	}

	// Post-commit: check low stock.
	var name string
	var stock float64
	var threshold *float64
	err = r.pool.QueryRow(ctx,
		`SELECT name, current_stock, low_stock_threshold FROM ingredients WHERE id = $1`, ingredientID,
	).Scan(&name, &stock, &threshold)
	if err == nil && threshold != nil && stock < *threshold {
		details, _ := json.Marshal(map[string]any{"current_stock": stock, "threshold": *threshold})
		r.pool.Exec(ctx,
			`INSERT INTO alerts (alert_type, ingredient_id, message, details)
			 VALUES ('low_stock', $1, $2, $3)`,
			ingredientID,
			fmt.Sprintf("%s is low on stock (%.2f remaining, threshold: %.2f)", name, stock, *threshold),
			details,
		)
	}

	return rec, nil
}

func (r *StockRepo) ListWastageRecords(ctx context.Context, ingredientFilter, typeFilter string) ([]model.WastageRecord, error) {
	query := `SELECT wr.id, wr.ingredient_id, wr.quantity, wr.wastage_type, wr.wastage_date,
	                 COALESCE(wr.notes,''), wr.created_by, wr.created_at,
	                 i.name, u.abbreviation
	          FROM wastage_records wr
	          JOIN ingredients i ON i.id = wr.ingredient_id
	          JOIN units u ON u.id = i.unit_id
	          WHERE 1=1`
	var args []any
	argN := 1

	if ingredientFilter != "" {
		query += fmt.Sprintf(` AND wr.ingredient_id = $%d`, argN)
		args = append(args, ingredientFilter)
		argN++
	}
	if typeFilter != "" {
		query += fmt.Sprintf(` AND wr.wastage_type = $%d`, argN)
		args = append(args, typeFilter)
		argN++
	}

	query += ` ORDER BY wr.wastage_date DESC, wr.created_at DESC`

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var records []model.WastageRecord
	for rows.Next() {
		var rec model.WastageRecord
		if err := rows.Scan(
			&rec.ID, &rec.IngredientID, &rec.Quantity, &rec.WastageType, &rec.WastageDate,
			&rec.Notes, &rec.CreatedBy, &rec.CreatedAt,
			&rec.IngredientName, &rec.UnitAbbr,
		); err != nil {
			return nil, err
		}
		records = append(records, rec)
	}
	return records, rows.Err()
}

// ---------------------------------------------------------------------------
// Stock movements
// ---------------------------------------------------------------------------

func (r *StockRepo) RecordMovement(ctx context.Context, tx pgx.Tx, ingredientID uuid.UUID, quantity float64, movementType, refType string, refID *uuid.UUID, notes string, userID uuid.UUID) error {
	q := `INSERT INTO stock_movements (ingredient_id, quantity, movement_type, reference_type, reference_id, notes, created_by)
	      VALUES ($1, $2, $3, $4, $5, $6, $7)`
	if tx != nil {
		_, err := tx.Exec(ctx, q, ingredientID, quantity, movementType, refType, refID, notes, userID)
		return err
	}
	_, err := r.pool.Exec(ctx, q, ingredientID, quantity, movementType, refType, refID, notes, userID)
	return err
}

func (r *StockRepo) ListStockMovements(ctx context.Context, ingredientFilter, typeFilter string, limit int) ([]model.StockMovement, error) {
	query := `SELECT sm.id, sm.ingredient_id, sm.quantity, sm.movement_type,
	                 COALESCE(sm.reference_type,''), sm.reference_id, COALESCE(sm.notes,''),
	                 sm.created_by, sm.created_at,
	                 i.name, u.abbreviation
	          FROM stock_movements sm
	          JOIN ingredients i ON i.id = sm.ingredient_id
	          JOIN units u ON u.id = i.unit_id
	          WHERE 1=1`
	var args []any
	argN := 1

	if ingredientFilter != "" {
		query += fmt.Sprintf(` AND sm.ingredient_id = $%d`, argN)
		args = append(args, ingredientFilter)
		argN++
	}
	if typeFilter != "" {
		query += fmt.Sprintf(` AND sm.movement_type = $%d`, argN)
		args = append(args, typeFilter)
		argN++
	}

	query += ` ORDER BY sm.created_at DESC`

	if limit > 0 {
		query += fmt.Sprintf(` LIMIT $%d`, argN)
		args = append(args, limit)
	}

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var movements []model.StockMovement
	for rows.Next() {
		var m model.StockMovement
		if err := rows.Scan(
			&m.ID, &m.IngredientID, &m.Quantity, &m.MovementType,
			&m.ReferenceType, &m.ReferenceID, &m.Notes,
			&m.CreatedBy, &m.CreatedAt,
			&m.IngredientName, &m.UnitAbbr,
		); err != nil {
			return nil, err
		}
		movements = append(movements, m)
	}
	return movements, rows.Err()
}

func (r *StockRepo) GetMovementSummary(ctx context.Context, days int) (map[string]float64, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT movement_type, COALESCE(SUM(ABS(quantity)), 0)
		 FROM stock_movements
		 WHERE created_at >= NOW() - ($1 || ' days')::interval
		 GROUP BY movement_type`, days)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	summary := make(map[string]float64)
	for rows.Next() {
		var mtype string
		var total float64
		if err := rows.Scan(&mtype, &total); err != nil {
			return nil, err
		}
		summary[mtype] = total
	}
	return summary, rows.Err()
}
