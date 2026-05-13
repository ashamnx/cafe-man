package middleware

import (
	"log/slog"
	"net/http"

	"searlo-cafe/internal/repository"
)

// RequirePermission checks that the authenticated user has the specified permission
// in the current tenant database.
func RequirePermission(resource, action string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userID := GetUserID(r.Context())
			pool := TenantPool(r.Context())

			if pool == nil {
				http.Error(w, "Forbidden", http.StatusForbidden)
				return
			}

			rbacRepo := repository.NewRBACRepo(pool)
			perms, err := rbacRepo.GetUserPermissions(r.Context(), userID)
			if err != nil {
				slog.Error("failed to get permissions", "error", err)
				http.Error(w, "Internal Server Error", http.StatusInternalServerError)
				return
			}

			for _, p := range perms {
				if p.Resource == resource && p.Action == action {
					next.ServeHTTP(w, r)
					return
				}
			}

			// For HTMX requests, return 403 with a message fragment.
			if r.Header.Get("HX-Request") == "true" {
				w.WriteHeader(http.StatusForbidden)
				w.Write([]byte(`<div class="alert alert-danger">You don't have permission to perform this action.</div>`))
				return
			}

			http.Error(w, "Forbidden", http.StatusForbidden)
		})
	}
}
