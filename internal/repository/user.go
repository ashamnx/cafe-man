package repository

import (
	"context"
	"errors"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("not found")
var ErrDuplicate = errors.New("already exists")

type UserRepo struct {
	pool *pgxpool.Pool
}

func NewUserRepo(pool *pgxpool.Pool) *UserRepo {
	return &UserRepo{pool: pool}
}

func (r *UserRepo) Create(ctx context.Context, email, passwordHash, fullName string) (*model.User, error) {
	u := &model.User{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO users (email, password_hash, full_name)
		 VALUES ($1, $2, $3)
		 RETURNING id, email, password_hash, full_name, is_active, must_reset_password, created_at, updated_at`,
		email, passwordHash, fullName,
	).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName, &u.IsActive, &u.MustResetPassword, &u.CreatedAt, &u.UpdatedAt)

	if err != nil {
		if isDuplicateError(err) {
			return nil, ErrDuplicate
		}
		return nil, err
	}
	return u, nil
}

func (r *UserRepo) CreateWithTempPassword(ctx context.Context, email, passwordHash, fullName string) (*model.User, error) {
	u := &model.User{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO users (email, password_hash, full_name, must_reset_password)
		 VALUES ($1, $2, $3, true)
		 RETURNING id, email, password_hash, full_name, is_active, must_reset_password, created_at, updated_at`,
		email, passwordHash, fullName,
	).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName, &u.IsActive, &u.MustResetPassword, &u.CreatedAt, &u.UpdatedAt)

	if err != nil {
		if isDuplicateError(err) {
			return nil, ErrDuplicate
		}
		return nil, err
	}
	return u, nil
}

func (r *UserRepo) UpdatePassword(ctx context.Context, userID uuid.UUID, newPasswordHash string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE users SET password_hash = $1, must_reset_password = false, updated_at = NOW() WHERE id = $2`,
		newPasswordHash, userID,
	)
	return err
}

func (r *UserRepo) GetByEmail(ctx context.Context, email string) (*model.User, error) {
	u := &model.User{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, full_name, is_active, must_reset_password, created_at, updated_at
		 FROM users WHERE email = $1`,
		email,
	).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName, &u.IsActive, &u.MustResetPassword, &u.CreatedAt, &u.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return u, err
}

func (r *UserRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.User, error) {
	u := &model.User{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, full_name, is_active, must_reset_password, created_at, updated_at
		 FROM users WHERE id = $1`,
		id,
	).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName, &u.IsActive, &u.MustResetPassword, &u.CreatedAt, &u.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return u, err
}

func isDuplicateError(err error) bool {
	return err != nil && contains(err.Error(), "duplicate key")
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && searchString(s, substr)
}

func searchString(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
