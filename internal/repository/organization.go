package repository

import (
	"context"
	"errors"
	"time"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type OrganizationRepo struct {
	pool *pgxpool.Pool
}

func NewOrganizationRepo(pool *pgxpool.Pool) *OrganizationRepo {
	return &OrganizationRepo{pool: pool}
}

func (r *OrganizationRepo) Create(ctx context.Context, name, slug, dbName, currencyCode, currencySymbol string) (*model.Organization, error) {
	org := &model.Organization{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO organizations (name, slug, db_name, currency_code, currency_symbol)
		 VALUES ($1, $2, $3, $4, $5)
		 RETURNING id, name, slug, db_name, currency_code, currency_symbol, COALESCE(logo_image_key,''), is_active, created_at, updated_at`,
		name, slug, dbName, currencyCode, currencySymbol,
	).Scan(&org.ID, &org.Name, &org.Slug, &org.DBName, &org.CurrencyCode, &org.CurrencySymbol, &org.LogoImageKey, &org.IsActive, &org.CreatedAt, &org.UpdatedAt)

	if err != nil {
		if isDuplicateError(err) {
			return nil, ErrDuplicate
		}
		return nil, err
	}
	return org, nil
}

func (r *OrganizationRepo) GetBySlug(ctx context.Context, slug string) (*model.Organization, error) {
	org := &model.Organization{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, slug, db_name, currency_code, currency_symbol, COALESCE(logo_image_key,''), is_active, created_at, updated_at
		 FROM organizations WHERE slug = $1`,
		slug,
	).Scan(&org.ID, &org.Name, &org.Slug, &org.DBName, &org.CurrencyCode, &org.CurrencySymbol, &org.LogoImageKey, &org.IsActive, &org.CreatedAt, &org.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return org, err
}

func (r *OrganizationRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Organization, error) {
	org := &model.Organization{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, slug, db_name, currency_code, currency_symbol, COALESCE(logo_image_key,''), is_active, created_at, updated_at
		 FROM organizations WHERE id = $1`,
		id,
	).Scan(&org.ID, &org.Name, &org.Slug, &org.DBName, &org.CurrencyCode, &org.CurrencySymbol, &org.LogoImageKey, &org.IsActive, &org.CreatedAt, &org.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return org, err
}

func (r *OrganizationRepo) UpdateLogo(ctx context.Context, id uuid.UUID, key string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE organizations SET logo_image_key = NULLIF($1,''), updated_at = NOW() WHERE id = $2`,
		key, id,
	)
	return err
}

func (r *OrganizationRepo) AddUser(ctx context.Context, userID, orgID uuid.UUID, isOwner bool) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO user_organizations (user_id, organization_id, is_owner)
		 VALUES ($1, $2, $3)
		 ON CONFLICT DO NOTHING`,
		userID, orgID, isOwner,
	)
	return err
}

func (r *OrganizationRepo) GetUserOrgs(ctx context.Context, userID uuid.UUID) ([]model.Organization, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT o.id, o.name, o.slug, o.db_name, o.currency_code, o.currency_symbol, COALESCE(o.logo_image_key,''), o.is_active, o.created_at, o.updated_at
		 FROM organizations o
		 JOIN user_organizations uo ON uo.organization_id = o.id
		 WHERE uo.user_id = $1 AND o.is_active = true
		 ORDER BY o.name`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orgs []model.Organization
	for rows.Next() {
		var org model.Organization
		if err := rows.Scan(&org.ID, &org.Name, &org.Slug, &org.DBName, &org.CurrencyCode, &org.CurrencySymbol, &org.LogoImageKey, &org.IsActive, &org.CreatedAt, &org.UpdatedAt); err != nil {
			return nil, err
		}
		orgs = append(orgs, org)
	}
	return orgs, rows.Err()
}

// OrgUserRow holds platform-side data for an org member (without tenant role info).
type OrgUserRow struct {
	UserID   uuid.UUID
	Email    string
	FullName string
	IsActive bool
	IsOwner  bool
	JoinedAt time.Time
}

func (r *OrganizationRepo) ListOrgUsers(ctx context.Context, orgID uuid.UUID) ([]OrgUserRow, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT u.id, u.email, u.full_name, u.is_active, uo.is_owner, uo.created_at
		 FROM users u
		 JOIN user_organizations uo ON uo.user_id = u.id
		 WHERE uo.organization_id = $1
		 ORDER BY uo.created_at`,
		orgID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []OrgUserRow
	for rows.Next() {
		var u OrgUserRow
		if err := rows.Scan(&u.UserID, &u.Email, &u.FullName, &u.IsActive, &u.IsOwner, &u.JoinedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

func (r *OrganizationRepo) RemoveUser(ctx context.Context, userID, orgID uuid.UUID) error {
	tag, err := r.pool.Exec(ctx,
		`DELETE FROM user_organizations WHERE user_id = $1 AND organization_id = $2`,
		userID, orgID,
	)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *OrganizationRepo) IsUserInOrg(ctx context.Context, userID, orgID uuid.UUID) (bool, error) {
	var count int
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM user_organizations WHERE user_id = $1 AND organization_id = $2`,
		userID, orgID,
	).Scan(&count)
	return count > 0, err
}
