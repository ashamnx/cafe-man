package migrate

import (
	"context"
	"embed"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

//go:embed platform/*.sql
var platformFS embed.FS

//go:embed tenant/*.sql
var tenantFS embed.FS

func RunPlatform(ctx context.Context, pool *pgxpool.Pool) error {
	migrations := []struct {
		path    string
		version int
	}{
		{"platform/000001_initial.up.sql", 1},
		{"platform/000002_api_tokens.up.sql", 2},
		{"platform/000003_user_invites.up.sql", 3},
		{"platform/000004_org_logo.up.sql", 4},
	}
	for _, m := range migrations {
		if err := runSQL(ctx, pool, platformFS, m.path, m.version); err != nil {
			return err
		}
	}
	return nil
}

func RunTenant(ctx context.Context, pool *pgxpool.Pool) error {
	migrations := []struct {
		path    string
		version int
	}{
		{"tenant/000001_initial.up.sql", 1},
		{"tenant/000002_menu_item_status.up.sql", 2},
		{"tenant/000003_bill_manual_entry.up.sql", 3},
		{"tenant/000004_ingredient_image.up.sql", 4},
		{"tenant/000005_bill_unit_conversion.up.sql", 5},
		{"tenant/000006_stock_movements.up.sql", 6},
		{"tenant/000007_audit_log.up.sql", 7},
		{"tenant/000008_ingredient_categories.up.sql", 8},
		{"tenant/000009_recipe_ingredient_display_unit.up.sql", 9},
		{"tenant/000010_utility_costs_v2.up.sql", 10},
		{"tenant/000011_menu_items_yield.up.sql", 11},
	}
	for _, m := range migrations {
		if err := runSQL(ctx, pool, tenantFS, m.path, m.version); err != nil {
			return err
		}
	}
	return nil
}

func runSQL(ctx context.Context, pool *pgxpool.Pool, fsys embed.FS, path string, version int) error {
	// Create tracking table.
	_, err := pool.Exec(ctx, `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version INT PRIMARY KEY,
			applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`)
	if err != nil {
		return fmt.Errorf("create migrations table: %w", err)
	}

	// Check if already applied.
	var count int
	pool.QueryRow(ctx, `SELECT COUNT(*) FROM schema_migrations WHERE version = $1`, version).Scan(&count)
	if count > 0 {
		return nil
	}

	sql, err := fsys.ReadFile(path)
	if err != nil {
		return fmt.Errorf("read migration %s: %w", path, err)
	}

	ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	if _, err := pool.Exec(ctx, string(sql)); err != nil {
		return fmt.Errorf("apply migration %s: %w", path, err)
	}

	if _, err := pool.Exec(ctx, `INSERT INTO schema_migrations (version) VALUES ($1)`, version); err != nil {
		return fmt.Errorf("record migration: %w", err)
	}

	return nil
}
