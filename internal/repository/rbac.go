package repository

import (
	"context"
	"errors"

	"searlo-cafe/internal/model"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type RBACRepo struct {
	pool *pgxpool.Pool
}

func NewRBACRepo(pool *pgxpool.Pool) *RBACRepo {
	return &RBACRepo{pool: pool}
}

// NewRBACRepoFromPool creates an RBACRepo that uses a dynamic pool (from context).
func NewRBACRepoFromPool() *RBACRepo {
	return &RBACRepo{}
}

func (r *RBACRepo) WithPool(pool *pgxpool.Pool) *RBACRepo {
	return &RBACRepo{pool: pool}
}

func (r *RBACRepo) GetUserPermissions(ctx context.Context, userID uuid.UUID) ([]model.Permission, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT p.id, p.resource, p.action, COALESCE(p.description, '')
		 FROM permissions p
		 JOIN role_permissions rp ON rp.permission_id = p.id
		 JOIN user_roles ur ON ur.role_id = rp.role_id
		 WHERE ur.user_id = $1`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var perms []model.Permission
	for rows.Next() {
		var p model.Permission
		if err := rows.Scan(&p.ID, &p.Resource, &p.Action, &p.Description); err != nil {
			return nil, err
		}
		perms = append(perms, p)
	}
	return perms, rows.Err()
}

func (r *RBACRepo) GetUserRoles(ctx context.Context, userID uuid.UUID) ([]model.Role, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT ro.id, ro.name, COALESCE(ro.description, ''), ro.is_system, ro.created_at
		 FROM roles ro
		 JOIN user_roles ur ON ur.role_id = ro.id
		 WHERE ur.user_id = $1`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var roles []model.Role
	for rows.Next() {
		var role model.Role
		if err := rows.Scan(&role.ID, &role.Name, &role.Description, &role.IsSystem, &role.CreatedAt); err != nil {
			return nil, err
		}
		roles = append(roles, role)
	}
	return roles, rows.Err()
}

func (r *RBACRepo) AssignRole(ctx context.Context, userID, roleID uuid.UUID) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO user_roles (user_id, role_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
		userID, roleID,
	)
	return err
}

func (r *RBACRepo) GetRoleByName(ctx context.Context, name string) (*model.Role, error) {
	role := &model.Role{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, name, COALESCE(description, ''), is_system, created_at FROM roles WHERE name = $1`,
		name,
	).Scan(&role.ID, &role.Name, &role.Description, &role.IsSystem, &role.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return role, err
}

func (r *RBACRepo) ListRoles(ctx context.Context) ([]model.Role, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, name, COALESCE(description, ''), is_system, created_at FROM roles ORDER BY name`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var roles []model.Role
	for rows.Next() {
		var role model.Role
		if err := rows.Scan(&role.ID, &role.Name, &role.Description, &role.IsSystem, &role.CreatedAt); err != nil {
			return nil, err
		}
		roles = append(roles, role)
	}
	return roles, rows.Err()
}

func (r *RBACRepo) ListPermissions(ctx context.Context) ([]model.Permission, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, resource, action, COALESCE(description, '') FROM permissions ORDER BY resource, action`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var perms []model.Permission
	for rows.Next() {
		var p model.Permission
		if err := rows.Scan(&p.ID, &p.Resource, &p.Action, &p.Description); err != nil {
			return nil, err
		}
		perms = append(perms, p)
	}
	return perms, rows.Err()
}

func (r *RBACRepo) RemoveUserRoles(ctx context.Context, userID uuid.UUID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM user_roles WHERE user_id = $1`, userID)
	return err
}

func (r *RBACRepo) ListRolesWithPermissions(ctx context.Context) ([]model.RoleWithPermissions, error) {
	roles, err := r.ListRoles(ctx)
	if err != nil {
		return nil, err
	}

	var result []model.RoleWithPermissions
	for _, role := range roles {
		perms, err := r.GetRolePermissions(ctx, role.ID)
		if err != nil {
			return nil, err
		}
		result = append(result, model.RoleWithPermissions{Role: role, Permissions: perms})
	}
	return result, nil
}

func (r *RBACRepo) GetRolePermissions(ctx context.Context, roleID uuid.UUID) ([]model.Permission, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT p.id, p.resource, p.action, COALESCE(p.description, '')
		 FROM permissions p
		 JOIN role_permissions rp ON rp.permission_id = p.id
		 WHERE rp.role_id = $1
		 ORDER BY p.resource, p.action`,
		roleID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var perms []model.Permission
	for rows.Next() {
		var p model.Permission
		if err := rows.Scan(&p.ID, &p.Resource, &p.Action, &p.Description); err != nil {
			return nil, err
		}
		perms = append(perms, p)
	}
	return perms, rows.Err()
}
