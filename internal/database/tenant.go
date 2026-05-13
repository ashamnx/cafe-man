package database

import (
	"context"
	"fmt"
	"log/slog"
	"net/url"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// MigrateFunc is called when a tenant pool is first created.
type MigrateFunc func(ctx context.Context, pool *pgxpool.Pool) error

// TenantManager manages per-tenant database connection pools.
type TenantManager struct {
	baseDSN   string
	mu        sync.RWMutex
	pools     map[string]*pgxpool.Pool
	onMigrate MigrateFunc
}

func NewTenantManager(baseDSN string) *TenantManager {
	return &TenantManager{
		baseDSN: baseDSN,
		pools:   make(map[string]*pgxpool.Pool),
	}
}

// SetMigrateFunc sets a callback that runs migrations when a tenant pool is first created.
func (tm *TenantManager) SetMigrateFunc(fn MigrateFunc) {
	tm.onMigrate = fn
}

// Pool returns a connection pool for the given tenant database name.
// Pools are lazily created, migrated, and cached.
func (tm *TenantManager) Pool(ctx context.Context, dbName string) (*pgxpool.Pool, error) {
	tm.mu.RLock()
	pool, ok := tm.pools[dbName]
	tm.mu.RUnlock()

	if ok {
		return pool, nil
	}

	tm.mu.Lock()
	defer tm.mu.Unlock()

	// Double-check after acquiring write lock.
	if pool, ok = tm.pools[dbName]; ok {
		return pool, nil
	}

	dsn, err := replaceDBName(tm.baseDSN, dbName)
	if err != nil {
		return nil, fmt.Errorf("build tenant dsn: %w", err)
	}

	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("parse tenant dsn: %w", err)
	}

	cfg.MaxConns = 3
	cfg.MinConns = 1
	cfg.MaxConnLifetime = 30 * time.Minute
	cfg.MaxConnIdleTime = 5 * time.Minute
	cfg.HealthCheckPeriod = 1 * time.Minute

	pool, err = pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("create tenant pool for %s: %w", dbName, err)
	}

	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("ping tenant db %s: %w", dbName, err)
	}

	// Run migrations on first connect.
	if tm.onMigrate != nil {
		if err := tm.onMigrate(ctx, pool); err != nil {
			slog.Error("tenant auto-migration failed", "db", dbName, "error", err)
			// Don't block — pool is usable, migration may have partially applied.
		} else {
			slog.Info("tenant auto-migration complete", "db", dbName)
		}
	}

	tm.pools[dbName] = pool
	return pool, nil
}

// CreateDatabase creates a new tenant database on the same cluster.
func (tm *TenantManager) CreateDatabase(ctx context.Context, platformPool *pgxpool.Pool, dbName string) error {
	for _, c := range dbName {
		if !((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_') {
			return fmt.Errorf("invalid database name: %s", dbName)
		}
	}
	_, err := platformPool.Exec(ctx, fmt.Sprintf("CREATE DATABASE %s", dbName))
	if err != nil {
		return fmt.Errorf("create database %s: %w", dbName, err)
	}
	return nil
}

// Close closes all tenant pools.
func (tm *TenantManager) Close() {
	tm.mu.Lock()
	defer tm.mu.Unlock()
	for _, pool := range tm.pools {
		pool.Close()
	}
	tm.pools = make(map[string]*pgxpool.Pool)
}

func replaceDBName(dsn, dbName string) (string, error) {
	u, err := url.Parse(dsn)
	if err != nil {
		return "", err
	}
	u.Path = "/" + dbName
	return u.String(), nil
}
