package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type BillRepo struct {
	pool *pgxpool.Pool
}

func NewBillRepo(pool *pgxpool.Pool) *BillRepo {
	return &BillRepo{pool: pool}
}

func (r *BillRepo) Create(ctx context.Context, vendorID *uuid.UUID, billNumber string, billDate *time.Time, imagePath *string, entryType string, createdBy uuid.UUID) (*model.VendorBill, error) {
	bill := &model.VendorBill{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO vendor_bills (vendor_id, bill_number, bill_date, image_path, entry_type, created_by)
		 VALUES ($1, $2, $3, $4, $5, $6)
		 RETURNING id, vendor_id, COALESCE(bill_number,''), bill_date, total_amount, COALESCE(image_path,''), entry_type, status, COALESCE(notes,''), created_by, created_at, updated_at`,
		vendorID, billNumber, billDate, imagePath, entryType, createdBy,
	).Scan(&bill.ID, &bill.VendorID, &bill.BillNumber, &bill.BillDate, &bill.TotalAmount, &bill.ImagePath, &bill.EntryType, &bill.Status, &bill.Notes, &bill.CreatedBy, &bill.CreatedAt, &bill.UpdatedAt)
	return bill, err
}

func (r *BillRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.VendorBill, error) {
	bill := &model.VendorBill{}
	err := r.pool.QueryRow(ctx,
		`SELECT b.id, b.vendor_id, COALESCE(b.bill_number,''), b.bill_date, b.total_amount,
		        COALESCE(b.image_path,''), b.entry_type, b.ai_raw_response, b.status, COALESCE(b.notes,''), b.created_by, b.created_at, b.updated_at,
		        COALESCE(v.name, '')
		 FROM vendor_bills b
		 LEFT JOIN vendors v ON v.id = b.vendor_id
		 WHERE b.id = $1`, id,
	).Scan(&bill.ID, &bill.VendorID, &bill.BillNumber, &bill.BillDate, &bill.TotalAmount,
		&bill.ImagePath, &bill.EntryType, &bill.AIRawResponse, &bill.Status, &bill.Notes, &bill.CreatedBy, &bill.CreatedAt, &bill.UpdatedAt,
		new(string))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	// Populate vendor if present.
	if err == nil && bill.VendorID != nil {
		var vendorName string
		r.pool.QueryRow(ctx, `SELECT COALESCE(name,'') FROM vendors WHERE id = $1`, bill.VendorID).Scan(&vendorName)
		bill.Vendor = &model.Vendor{Name: vendorName}
	}
	return bill, err
}

func (r *BillRepo) List(ctx context.Context, search, status, dateFrom, dateTo, sortBy string) ([]model.VendorBill, error) {
	query := `SELECT b.id, b.vendor_id, COALESCE(b.bill_number,''), b.bill_date, b.total_amount,
	                 COALESCE(b.image_path,''), b.entry_type, b.status, COALESCE(b.notes,''), b.created_by, b.created_at, b.updated_at,
	                 COALESCE(v.name, 'Unknown'),
	                 (SELECT COUNT(*) FROM vendor_bill_items WHERE bill_id = b.id)
	          FROM vendor_bills b
	          LEFT JOIN vendors v ON v.id = b.vendor_id
	          WHERE 1=1`
	var args []any
	argN := 1

	if search != "" {
		query += fmt.Sprintf(` AND (b.bill_number ILIKE '%%' || $%d || '%%' OR v.name ILIKE '%%' || $%d || '%%' OR EXISTS (SELECT 1 FROM vendor_bill_items bi LEFT JOIN ingredients i ON i.id = bi.ingredient_id WHERE bi.bill_id = b.id AND (i.name ILIKE '%%' || $%d || '%%' OR bi.raw_item_name ILIKE '%%' || $%d || '%%')))`, argN, argN, argN, argN)
		args = append(args, search)
		argN++
	}

	if status != "" {
		query += fmt.Sprintf(` AND b.status = $%d`, argN)
		args = append(args, status)
		argN++
	}

	if dateFrom != "" {
		query += fmt.Sprintf(` AND COALESCE(b.bill_date, b.created_at::date) >= $%d::date`, argN)
		args = append(args, dateFrom)
		argN++
	}

	if dateTo != "" {
		query += fmt.Sprintf(` AND COALESCE(b.bill_date, b.created_at::date) <= $%d::date`, argN)
		args = append(args, dateTo)
		argN++
	}

	switch sortBy {
	case "date_asc":
		query += ` ORDER BY COALESCE(b.bill_date, b.created_at::date) ASC, b.created_at ASC`
	case "date_desc":
		query += ` ORDER BY COALESCE(b.bill_date, b.created_at::date) DESC, b.created_at DESC`
	case "amount_asc":
		query += ` ORDER BY b.total_amount ASC NULLS LAST, b.created_at DESC`
	case "amount_desc":
		query += ` ORDER BY b.total_amount DESC NULLS LAST, b.created_at DESC`
	default:
		query += ` ORDER BY b.created_at DESC`
	}

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bills []model.VendorBill
	for rows.Next() {
		var b model.VendorBill
		var vendorName string
		if err := rows.Scan(&b.ID, &b.VendorID, &b.BillNumber, &b.BillDate, &b.TotalAmount,
			&b.ImagePath, &b.EntryType, &b.Status, &b.Notes, &b.CreatedBy, &b.CreatedAt, &b.UpdatedAt,
			&vendorName, &b.ItemCount); err != nil {
			return nil, err
		}
		if b.VendorID != nil {
			b.Vendor = &model.Vendor{Name: vendorName}
		}
		bills = append(bills, b)
	}
	return bills, rows.Err()
}

func (r *BillRepo) Update(ctx context.Context, id uuid.UUID, vendorID *uuid.UUID, billNumber string, billDate *time.Time, totalAmount *float64, notes, imagePath string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE vendor_bills SET vendor_id=$1, bill_number=$2, bill_date=$3, total_amount=$4, notes=$5, image_path=$6, updated_at=NOW()
		 WHERE id=$7`,
		vendorID, billNumber, billDate, totalAmount, notes, nilIfEmpty(imagePath), id,
	)
	return err
}

func (r *BillRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM vendor_bills WHERE id = $1`, id)
	return err
}

func (r *BillRepo) UpdateAIResponse(ctx context.Context, id uuid.UUID, raw json.RawMessage, status string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE vendor_bills SET ai_raw_response = $1, status = $2, updated_at = NOW() WHERE id = $3`,
		raw, status, id,
	)
	return err
}

func (r *BillRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE vendor_bills SET status = $1, updated_at = NOW() WHERE id = $2`,
		status, id,
	)
	return err
}

func (r *BillRepo) CreateItem(ctx context.Context, item model.VendorBillItem) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO vendor_bill_items (bill_id, raw_item_name, raw_quantity, raw_unit, raw_unit_price, raw_total_price, ingredient_id, bill_unit_id, mapped_quantity, mapped_unit_price, mapping_status, mapped_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
		item.BillID, item.RawItemName, item.RawQuantity, item.RawUnit, item.RawUnitPrice, item.RawTotalPrice,
		item.IngredientID, item.BillUnitID, item.MappedQuantity, item.MappedUnitPrice, item.MappingStatus, item.MappedAt,
	)
	return err
}

func (r *BillRepo) GetBillItems(ctx context.Context, billID uuid.UUID) ([]model.VendorBillItem, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT bi.id, bi.bill_id, bi.raw_item_name, bi.raw_quantity, bi.raw_unit, bi.raw_unit_price, bi.raw_total_price,
		        bi.ingredient_id, bi.bill_unit_id, bi.mapped_quantity, bi.mapped_unit_price, bi.mapping_status, bi.mapped_at, bi.created_at,
		        COALESCE(i.name, ''), COALESCE(i.image_path, '')
		 FROM vendor_bill_items bi
		 LEFT JOIN ingredients i ON i.id = bi.ingredient_id
		 WHERE bi.bill_id = $1
		 ORDER BY bi.created_at`, billID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.VendorBillItem
	for rows.Next() {
		var item model.VendorBillItem
		var ingredientName, ingredientImagePath string
		if err := rows.Scan(&item.ID, &item.BillID, &item.RawItemName, &item.RawQuantity, &item.RawUnit,
			&item.RawUnitPrice, &item.RawTotalPrice, &item.IngredientID, &item.BillUnitID, &item.MappedQuantity,
			&item.MappedUnitPrice, &item.MappingStatus, &item.MappedAt, &item.CreatedAt,
			&ingredientName, &ingredientImagePath); err != nil {
			return nil, err
		}
		if item.IngredientID != nil {
			item.Ingredient = &model.Ingredient{Name: ingredientName, ImagePath: ingredientImagePath}
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *BillRepo) DeleteItem(ctx context.Context, itemID uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM vendor_bill_items WHERE id = $1`, itemID)
	return err
}

func (r *BillRepo) MapItem(ctx context.Context, itemID, ingredientID uuid.UUID, billUnitID *uuid.UUID, mappedQty float64, mappedUnitPrice *float64) error {
	now := time.Now()
	_, err := r.pool.Exec(ctx,
		`UPDATE vendor_bill_items SET ingredient_id = $1, bill_unit_id = $2, mapped_quantity = $3, mapped_unit_price = $4, mapping_status = 'manually_mapped', mapped_at = $5
		 WHERE id = $6`,
		ingredientID, billUnitID, mappedQty, mappedUnitPrice, now, itemID,
	)
	return err
}

func (r *BillRepo) GetRecentBillsForIngredient(ctx context.Context, ingredientID uuid.UUID, limit int) ([]model.VendorBill, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT ON (b.id) b.id, b.vendor_id, COALESCE(b.bill_number,''), b.bill_date, b.total_amount,
		        COALESCE(b.image_path,''), b.entry_type, b.status, COALESCE(b.notes,''),
		        b.created_by, b.created_at, b.updated_at,
		        COALESCE(v.name, 'Unknown')
		 FROM vendor_bills b
		 JOIN vendor_bill_items bi ON bi.bill_id = b.id
		 LEFT JOIN vendors v ON v.id = b.vendor_id
		 WHERE bi.ingredient_id = $1
		 ORDER BY b.id, b.created_at DESC`, ingredientID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bills []model.VendorBill
	for rows.Next() {
		var b model.VendorBill
		var vendorName string
		if err := rows.Scan(&b.ID, &b.VendorID, &b.BillNumber, &b.BillDate, &b.TotalAmount,
			&b.ImagePath, &b.EntryType, &b.Status, &b.Notes, &b.CreatedBy, &b.CreatedAt, &b.UpdatedAt,
			&vendorName); err != nil {
			return nil, err
		}
		if b.VendorID != nil {
			b.Vendor = &model.Vendor{Name: vendorName}
		}
		bills = append(bills, b)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Sort by created_at DESC and apply limit (DISTINCT ON requires ORDER BY on the same column first).
	// Re-sort in Go since DISTINCT ON forces ordering by b.id.
	sortBillsByCreatedAtDesc(bills)
	if limit > 0 && len(bills) > limit {
		bills = bills[:limit]
	}
	return bills, nil
}

func sortBillsByCreatedAtDesc(bills []model.VendorBill) {
	for i := 1; i < len(bills); i++ {
		for j := i; j > 0 && bills[j].CreatedAt.After(bills[j-1].CreatedAt); j-- {
			bills[j], bills[j-1] = bills[j-1], bills[j]
		}
	}
}

func nilIfEmpty(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
