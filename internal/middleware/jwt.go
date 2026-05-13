package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// RequireJWT authenticates API requests via Bearer token.
// It injects the same context keys (UserIDKey, OrgIDKey, OrgDBKey) as RequireAuth,
// so all downstream middleware (RequireOrg, InjectTenantPool, RequirePermission) works unchanged.
func RequireJWT(secret string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				http.Error(w, `{"error":"missing or invalid authorization header"}`, http.StatusUnauthorized)
				return
			}

			tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

			token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (any, error) {
				if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, jwt.ErrSignatureInvalid
				}
				return []byte(secret), nil
			})
			if err != nil || !token.Valid {
				http.Error(w, `{"error":"invalid or expired token"}`, http.StatusUnauthorized)
				return
			}

			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				http.Error(w, `{"error":"invalid token claims"}`, http.StatusUnauthorized)
				return
			}

			sub, _ := claims["sub"].(string)
			userID, err := uuid.Parse(sub)
			if err != nil {
				http.Error(w, `{"error":"invalid user in token"}`, http.StatusUnauthorized)
				return
			}

			ctx := r.Context()
			ctx = context.WithValue(ctx, UserIDKey, userID)

			if orgIDStr, _ := claims["org_id"].(string); orgIDStr != "" {
				if orgID, err := uuid.Parse(orgIDStr); err == nil {
					ctx = context.WithValue(ctx, OrgIDKey, orgID)
				}
			}

			if orgDB, _ := claims["org_db"].(string); orgDB != "" {
				ctx = context.WithValue(ctx, OrgDBKey, orgDB)
			}

			if userName, _ := claims["user_name"].(string); userName != "" {
				ctx = context.WithValue(ctx, UserNameKey, userName)
			}

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// RequireOrgAPI is the API-specific version of RequireOrg.
// Returns JSON 403 instead of redirecting to /select-org.
func RequireOrgAPI(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if GetOrgDB(r.Context()) == "" {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusForbidden)
			w.Write([]byte(`{"error":"no organization selected"}`))
			return
		}
		next.ServeHTTP(w, r)
	})
}

// RequirePermissionAPI is the API-specific version of RequirePermission.
// Returns JSON errors instead of HTML fragments.
func RequirePermissionAPI(resource, action string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Delegate to the same permission check logic but with JSON error responses.
			userID := GetUserID(r.Context())
			pool := TenantPool(r.Context())

			if pool == nil {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusForbidden)
				w.Write([]byte(`{"error":"forbidden"}`))
				return
			}

			// Import would cause cycle, so we use the repository inline.
			// We replicate the permission check from rbac.go.
			var hasPermission bool
			rows, err := pool.Query(r.Context(), `
				SELECT p.resource, p.action
				FROM user_roles ur
				JOIN role_permissions rp ON rp.role_id = ur.role_id
				JOIN permissions p ON p.id = rp.permission_id
				WHERE ur.user_id = $1`, userID)
			if err == nil {
				defer rows.Close()
				for rows.Next() {
					var res, act string
					if err := rows.Scan(&res, &act); err == nil {
						if res == resource && act == action {
							hasPermission = true
							break
						}
					}
				}
			}

			if !hasPermission {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusForbidden)
				w.Write([]byte(`{"error":"you don't have permission to perform this action"}`))
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
