package apihandler

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/service"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type UserAPIHandler struct {
	auth         *service.AuthService
	platformPool *pgxpool.Pool
}

func NewUserAPIHandler(auth *service.AuthService, platformPool *pgxpool.Pool) *UserAPIHandler {
	return &UserAPIHandler{auth: auth, platformPool: platformPool}
}

func (h *UserAPIHandler) RegisterRoutes(mux *http.ServeMux, wrap func(http.HandlerFunc, ...string) http.Handler) {
	mux.Handle("GET /api/v1/users", wrap(h.list, "users", "read"))
	mux.Handle("POST /api/v1/users/invite", wrap(h.invite, "users", "create"))
	mux.Handle("PUT /api/v1/users/{id}/role", wrap(h.changeRole, "users", "update"))
	mux.Handle("POST /api/v1/users/{id}/reset-password", wrap(h.resetPassword, "users", "update"))
	mux.Handle("DELETE /api/v1/users/{id}", wrap(h.remove, "users", "delete"))
	mux.Handle("GET /api/v1/roles", wrap(h.listRoles, "roles", "read"))
	mux.Handle("GET /api/v1/roles/{id}", wrap(h.showRole, "roles", "read"))
}

func (h *UserAPIHandler) list(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	orgID := middleware.GetOrgID(r.Context())

	orgRepo := repository.NewOrganizationRepo(h.platformPool)
	platformUsers, err := orgRepo.ListOrgUsers(r.Context(), orgID)
	if err != nil {
		slog.Error("api: list org users", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list users")
		return
	}

	rbacRepo := repository.NewRBACRepo(pool)
	type memberResponse struct {
		UserID   uuid.UUID `json:"user_id"`
		Email    string    `json:"email"`
		FullName string    `json:"full_name"`
		IsActive bool      `json:"is_active"`
		IsOwner  bool      `json:"is_owner"`
		Roles    []string  `json:"roles"`
		JoinedAt string    `json:"joined_at"`
	}

	members := make([]memberResponse, 0, len(platformUsers))
	for _, pu := range platformUsers {
		roles, _ := rbacRepo.GetUserRoles(r.Context(), pu.UserID)
		roleNames := make([]string, 0, len(roles))
		for _, ro := range roles {
			roleNames = append(roleNames, ro.Name)
		}
		members = append(members, memberResponse{
			UserID:   pu.UserID,
			Email:    pu.Email,
			FullName: pu.FullName,
			IsActive: pu.IsActive,
			IsOwner:  pu.IsOwner,
			Roles:    roleNames,
			JoinedAt: pu.JoinedAt.Format("2006-01-02T15:04:05Z"),
		})
	}

	writeJSON(w, http.StatusOK, members)
}

type inviteRequest struct {
	Email    string `json:"email"`
	FullName string `json:"full_name"`
	Role     string `json:"role"`
}

func (h *UserAPIHandler) invite(w http.ResponseWriter, r *http.Request) {
	var req inviteRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	req.FullName = strings.TrimSpace(req.FullName)
	req.Role = strings.TrimSpace(req.Role)

	if req.Email == "" || req.Role == "" {
		writeError(w, http.StatusBadRequest, "email and role are required")
		return
	}

	pool := middleware.TenantPool(r.Context())
	user, tempPassword, err := h.auth.InviteUser(r.Context(), service.InviteInput{
		Email:    req.Email,
		FullName: req.FullName,
		OrgID:    middleware.GetOrgID(r.Context()),
		RoleName: req.Role,
	}, pool)
	if err != nil {
		slog.Error("api: invite user", "error", err)
		if strings.Contains(err.Error(), "already in this organization") {
			writeError(w, http.StatusConflict, "user is already in this organization")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to invite user")
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	newJSON, _ := json.Marshal(map[string]any{"email": user.Email, "full_name": user.FullName, "role": req.Role})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"create", "user", user.ID, nil, newJSON, middleware.GetIPAddress(r))

	resp := map[string]any{
		"user":    user,
		"message": "user invited successfully",
	}
	if tempPassword != "" {
		resp["temp_password"] = tempPassword
	}

	writeJSON(w, http.StatusCreated, resp)
}

type changeRoleRequest struct {
	Role string `json:"role"`
}

func (h *UserAPIHandler) changeRole(w http.ResponseWriter, r *http.Request) {
	var req changeRoleRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Role == "" {
		writeError(w, http.StatusBadRequest, "role is required")
		return
	}

	userID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	pool := middleware.TenantPool(r.Context())

	// Get old roles for audit.
	rbacRepo := repository.NewRBACRepo(pool)
	oldRoles, _ := rbacRepo.GetUserRoles(r.Context(), userID)

	if err := h.auth.ChangeUserRole(r.Context(), userID, req.Role, pool); err != nil {
		slog.Error("api: change role", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to change role")
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	oldRoleNames := make([]string, 0, len(oldRoles))
	for _, ro := range oldRoles {
		oldRoleNames = append(oldRoleNames, ro.Name)
	}
	oldJSON, _ := json.Marshal(map[string]any{"roles": oldRoleNames})
	newJSON, _ := json.Marshal(map[string]any{"roles": []string{req.Role}})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"update", "user", userID, oldJSON, newJSON, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, map[string]string{"message": "role updated"})
}

func (h *UserAPIHandler) resetPassword(w http.ResponseWriter, r *http.Request) {
	userID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	newPassword, err := h.auth.ResetPassword(r.Context(), userID)
	if err != nil {
		slog.Error("api: reset password", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to reset password")
		return
	}

	// Log audit.
	pool := middleware.TenantPool(r.Context())
	auditRepo := repository.NewAuditRepo(pool)
	newJSON, _ := json.Marshal(map[string]any{"action": "password_reset"})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"update", "user", userID, nil, newJSON, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, map[string]string{
		"message":      "password reset successfully",
		"new_password": newPassword,
	})
}

func (h *UserAPIHandler) remove(w http.ResponseWriter, r *http.Request) {
	userID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid user id")
		return
	}

	currentUserID := middleware.GetUserID(r.Context())
	if userID == currentUserID {
		writeError(w, http.StatusBadRequest, "cannot remove yourself from the organization")
		return
	}

	pool := middleware.TenantPool(r.Context())
	orgID := middleware.GetOrgID(r.Context())

	// Get user info for audit.
	userRepo := repository.NewUserRepo(h.platformPool)
	removedUser, _ := userRepo.GetByID(r.Context(), userID)

	if err := h.auth.RemoveUserFromOrg(r.Context(), userID, orgID, pool); err != nil {
		slog.Error("api: remove user", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to remove user")
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	var oldJSON json.RawMessage
	if removedUser != nil {
		oldJSON, _ = json.Marshal(map[string]any{"email": removedUser.Email, "full_name": removedUser.FullName})
	}
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"delete", "user", userID, oldJSON, nil, middleware.GetIPAddress(r))

	writeJSON(w, http.StatusOK, map[string]string{"message": "user removed"})
}

func (h *UserAPIHandler) listRoles(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	rbacRepo := repository.NewRBACRepo(pool)

	roles, err := rbacRepo.ListRolesWithPermissions(r.Context())
	if err != nil {
		slog.Error("api: list roles", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to list roles")
		return
	}

	writeJSON(w, http.StatusOK, roles)
}

func (h *UserAPIHandler) showRole(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	rbacRepo := repository.NewRBACRepo(pool)

	roleID, err := uuid.Parse(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid role id")
		return
	}

	perms, err := rbacRepo.GetRolePermissions(r.Context(), roleID)
	if err != nil {
		slog.Error("api: get role permissions", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to get role")
		return
	}

	roles, _ := rbacRepo.ListRoles(r.Context())
	for _, ro := range roles {
		if ro.ID == roleID {
			writeJSON(w, http.StatusOK, map[string]any{
				"role":        ro,
				"permissions": perms,
			})
			return
		}
	}

	writeError(w, http.StatusNotFound, "role not found")
}
