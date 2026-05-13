package middleware

import (
	"context"
	"log/slog"
	"net/http"

	"searlo-cafe/internal/database"

	"github.com/jackc/pgx/v5/pgxpool"
)

type tenantPoolKey struct{}

// InjectTenantPool resolves the tenant DB pool from the org_db in context
// and injects it for downstream handlers.
func InjectTenantPool(tm *database.TenantManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			dbName := GetOrgDB(r.Context())
			if dbName == "" {
				http.Redirect(w, r, "/select-org", http.StatusSeeOther)
				return
			}

			pool, err := tm.Pool(r.Context(), dbName)
			if err != nil {
				slog.Error("failed to get tenant pool", "db", dbName, "error", err)
				http.Error(w, "Internal Server Error", http.StatusInternalServerError)
				return
			}

			ctx := context.WithValue(r.Context(), tenantPoolKey{}, pool)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// TenantPool retrieves the tenant database pool from the request context.
func TenantPool(ctx context.Context) *pgxpool.Pool {
	pool, _ := ctx.Value(tenantPoolKey{}).(*pgxpool.Pool)
	return pool
}
