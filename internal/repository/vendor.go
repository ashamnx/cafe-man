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

type VendorRepo struct {
	pool *pgxpool.Pool
}

func NewVendorRepo(pool *pgxpool.Pool) *VendorRepo {
	return &VendorRepo{pool: pool}
}

func (r *VendorRepo) List(ctx context.Context, search, sortBy string) ([]model.Vendor, error) {
	query := `SELECT id, name, COALESCE(contact_name,''), COALESCE(phone,''),
	                 COALESCE(email,''), COALESCE(address,''), COALESCE(notes,''),
	                 is_active, created_at, updated_at
	          FROM vendors WHERE is_active = true`
	var args []any
	argN := 1

	if search != "" {
		query += fmt.Sprintf(` AND (name ILIKE '%%' || $%d || '%%' OR contact_name ILIKE '%%' || $%d || '%%')`, argN, argN)
		args = append(args, search)
		argN++
	}

	switch sortBy {
	case "recent":
		query += ` ORDER BY created_at DESC`
	default:
		query += ` ORDER BY name`
	}

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var vendors []model.Vendor
	for rows.Next() {
		var v model.Vendor
		if err := rows.Scan(&v.ID, &v.Name, &v.ContactName, &v.Phone, &v.Email, &v.Address, &v.Notes, &v.IsActive, &v.CreatedAt, &v.UpdatedAt); err != nil {
			return nil, err
		}
		vendors = append(vendors, v)
	}
	return vendors, rows.Err()
}

func (r *VendorRepo) GetIngredientCountsByVendor(ctx context.Context) (map[uuid.UUID]int, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT v.id, COUNT(DISTINCT bi.ingredient_id)
		 FROM vendors v
		 LEFT JOIN vendor_bills vb ON vb.vendor_id = v.id
		 LEFT JOIN vendor_bill_items bi ON bi.bill_id = vb.id AND bi.ingredient_id IS NOT NULL
		 WHERE v.is_active = true
		 GROUP BY v.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[uuid.UUID]int)
	for rows.Next() {
		var id uuid.UUID
		var count int
		if err := rows.Scan(&id, &count); err != nil {
			return nil, err
		}
		counts[id] = count
	}
	return counts, rows.Err()
}

func (r *VendorRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Vendor, error) {
	v := &model.Vendor{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, COALESCE(contact_name,''), COALESCE(phone,''),
		        COALESCE(email,''), COALESCE(address,''), COALESCE(notes,''),
		        is_active, created_at, updated_at
		 FROM vendors WHERE id = $1`, id,
	).Scan(&v.ID, &v.Name, &v.ContactName, &v.Phone, &v.Email, &v.Address, &v.Notes, &v.IsActive, &v.CreatedAt, &v.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return v, err
}

type CreateVendorParams struct {
	Name        string
	ContactName string
	Phone       string
	Email       string
	Address     string
	Notes       string
}

func (r *VendorRepo) Create(ctx context.Context, p CreateVendorParams) (*model.Vendor, error) {
	v := &model.Vendor{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO vendors (name, contact_name, phone, email, address, notes)
		 VALUES ($1, $2, $3, $4, $5, $6)
		 RETURNING id, name, contact_name, phone, email, address, notes, is_active, created_at, updated_at`,
		p.Name, p.ContactName, p.Phone, p.Email, p.Address, p.Notes,
	).Scan(&v.ID, &v.Name, &v.ContactName, &v.Phone, &v.Email, &v.Address, &v.Notes, &v.IsActive, &v.CreatedAt, &v.UpdatedAt)
	return v, err
}

func (r *VendorRepo) Update(ctx context.Context, id uuid.UUID, p CreateVendorParams) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE vendors SET name=$1, contact_name=$2, phone=$3, email=$4, address=$5, notes=$6, updated_at=NOW()
		 WHERE id=$7`,
		p.Name, p.ContactName, p.Phone, p.Email, p.Address, p.Notes, id,
	)
	return err
}

func (r *VendorRepo) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `UPDATE vendors SET is_active = false, updated_at = NOW() WHERE id = $1`, id)
	return err
}
