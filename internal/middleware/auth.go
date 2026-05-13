package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/alexedwards/scs/v2"
	"github.com/google/uuid"
)

type contextKey string

const (
	UserIDKey   contextKey = "user_id"
	UserNameKey contextKey = "user_name"
	OrgIDKey    contextKey = "org_id"
	OrgDBKey    contextKey = "org_db"
)

// RequireAuth redirects unauthenticated users to /login.
func RequireAuth(sm *scs.SessionManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userIDStr := sm.GetString(r.Context(), "user_id")
			if userIDStr == "" {
				http.Redirect(w, r, "/login", http.StatusSeeOther)
				return
			}

			userID, err := uuid.Parse(userIDStr)
			if err != nil {
				sm.Destroy(r.Context())
				http.Redirect(w, r, "/login", http.StatusSeeOther)
				return
			}

			ctx := context.WithValue(r.Context(), UserIDKey, userID)

			userName := sm.GetString(r.Context(), "user_name")
			if userName != "" {
				ctx = context.WithValue(ctx, UserNameKey, userName)
			}

			orgIDStr := sm.GetString(r.Context(), "org_id")
			if orgIDStr != "" {
				if orgID, err := uuid.Parse(orgIDStr); err == nil {
					ctx = context.WithValue(ctx, OrgIDKey, orgID)
				}
			}

			orgDB := sm.GetString(r.Context(), "org_db")
			if orgDB != "" {
				ctx = context.WithValue(ctx, OrgDBKey, orgDB)
			}

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// RequireOrg ensures the user has selected an organization.
func RequireOrg(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if GetOrgDB(r.Context()) == "" {
			http.Redirect(w, r, "/select-org", http.StatusSeeOther)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func GetUserID(ctx context.Context) uuid.UUID {
	id, _ := ctx.Value(UserIDKey).(uuid.UUID)
	return id
}

func GetOrgID(ctx context.Context) uuid.UUID {
	id, _ := ctx.Value(OrgIDKey).(uuid.UUID)
	return id
}

func GetOrgDB(ctx context.Context) string {
	db, _ := ctx.Value(OrgDBKey).(string)
	return db
}

func GetUserName(ctx context.Context) string {
	name, _ := ctx.Value(UserNameKey).(string)
	return name
}

// GetIPAddress extracts the client IP from the request.
func GetIPAddress(r *http.Request) string {
	if forwarded := r.Header.Get("X-Forwarded-For"); forwarded != "" {
		// Take the first IP in the chain.
		if idx := strings.Index(forwarded, ","); idx != -1 {
			return strings.TrimSpace(forwarded[:idx])
		}
		return strings.TrimSpace(forwarded)
	}
	if realIP := r.Header.Get("X-Real-IP"); realIP != "" {
		return realIP
	}
	// Strip port from RemoteAddr.
	addr := r.RemoteAddr
	if idx := strings.LastIndex(addr, ":"); idx != -1 {
		return addr[:idx]
	}
	return addr
}
