package handler

import (
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/service"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type UserHandler struct {
	render       *Renderer
	auth         *service.AuthService
	platformPool *pgxpool.Pool
}

func NewUserHandler(render *Renderer, auth *service.AuthService, platformPool *pgxpool.Pool) *UserHandler {
	return &UserHandler{render: render, auth: auth, platformPool: platformPool}
}

func (h *UserHandler) RegisterRoutes(mux *http.ServeMux, authMw, orgMw, tenantMw func(http.Handler) http.Handler) {
	wrap := func(handler http.HandlerFunc, perms ...string) http.Handler {
		var chain http.Handler = handler
		if len(perms) == 2 {
			chain = middleware.RequirePermission(perms[0], perms[1])(chain)
		}
		chain = tenantMw(chain)
		chain = orgMw(chain)
		chain = authMw(chain)
		return chain
	}

	mux.Handle("GET /settings/users", wrap(h.listUsers, "users", "read"))
	mux.Handle("GET /settings/users/invite", wrap(h.showInvite, "users", "create"))
	mux.Handle("POST /settings/users/invite", wrap(h.handleInvite, "users", "create"))
	mux.Handle("POST /settings/users/{id}/role", wrap(h.changeRole, "users", "update"))
	mux.Handle("POST /settings/users/{id}/reset-password", wrap(h.resetPassword, "users", "update"))
	mux.Handle("POST /settings/users/{id}", wrap(h.removeUser, "users", "delete"))

	mux.Handle("GET /settings/roles", wrap(h.listRoles, "roles", "read"))
	mux.Handle("GET /settings/roles/{id}", wrap(h.showRole, "roles", "read"))
}

func (h *UserHandler) listUsers(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	orgID := middleware.GetOrgID(r.Context())

	orgRepo := repository.NewOrganizationRepo(h.platformPool)
	platformUsers, err := orgRepo.ListOrgUsers(r.Context(), orgID)
	if err != nil {
		slog.Error("failed to list org users", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// Merge with tenant role data.
	rbacRepo := repository.NewRBACRepo(pool)
	members := make([]model.OrgMember, 0, len(platformUsers))
	for _, pu := range platformUsers {
		roles, err := rbacRepo.GetUserRoles(r.Context(), pu.UserID)
		if err != nil {
			slog.Error("failed to get user roles", "user_id", pu.UserID, "error", err)
			roles = nil
		}
		members = append(members, model.OrgMember{
			UserID:   pu.UserID,
			Email:    pu.Email,
			FullName: pu.FullName,
			IsActive: pu.IsActive,
			IsOwner:  pu.IsOwner,
			Roles:    roles,
			JoinedAt: pu.JoinedAt,
		})
	}

	data := map[string]any{
		"Title":   "Team Members",
		"Members": members,
		"Success": r.URL.Query().Get("success"),
		"Error":   r.URL.Query().Get("error"),
	}
	h.render.HTML(w, r, "users.html", data)
}

func (h *UserHandler) showInvite(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	rbacRepo := repository.NewRBACRepo(pool)

	roles, err := rbacRepo.ListRoles(r.Context())
	if err != nil {
		slog.Error("failed to list roles", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	data := map[string]any{
		"Title":          "Invite User",
		"AvailableRoles": roles,
		"Error":          r.URL.Query().Get("error"),
		"FormEmail":      "",
		"FormName":       "",
	}
	h.render.HTML(w, r, "user_invite.html", data)
}

func (h *UserHandler) handleInvite(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	email := strings.TrimSpace(r.FormValue("email"))
	fullName := strings.TrimSpace(r.FormValue("full_name"))
	roleName := r.FormValue("role")

	if email == "" || roleName == "" {
		h.renderInviteError(w, r, pool, "Email and role are required", email, fullName)
		return
	}

	user, tempPassword, err := h.auth.InviteUser(r.Context(), service.InviteInput{
		Email:    email,
		FullName: fullName,
		OrgID:    middleware.GetOrgID(r.Context()),
		RoleName: roleName,
	}, pool)
	if err != nil {
		slog.Error("failed to invite user", "error", err)
		errMsg := "Failed to invite user"
		if strings.Contains(err.Error(), "already in this organization") {
			errMsg = "This user is already in your organization"
		}
		h.renderInviteError(w, r, pool, errMsg, email, fullName)
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	newJSON := marshalAudit(map[string]any{"email": user.Email, "full_name": user.FullName, "role": roleName})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"create", "user", user.ID, nil, newJSON, middleware.GetIPAddress(r))

	successMsg := user.FullName + " has been invited as " + roleName
	if tempPassword != "" {
		successMsg += ". Temporary password: " + tempPassword
	}

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/users?success="+successMsg)
		return
	}
	http.Redirect(w, r, "/settings/users?success="+successMsg, http.StatusSeeOther)
}

func (h *UserHandler) renderInviteError(w http.ResponseWriter, r *http.Request, pool *pgxpool.Pool, errMsg, email, name string) {
	rbacRepo := repository.NewRBACRepo(pool)
	roles, _ := rbacRepo.ListRoles(r.Context())
	data := map[string]any{
		"Title":          "Invite User",
		"AvailableRoles": roles,
		"Error":          errMsg,
		"FormEmail":      email,
		"FormName":       name,
	}
	h.render.HTML(w, r, "user_invite.html", data)
}

func (h *UserHandler) changeRole(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	userIDStr := r.PathValue("id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	newRole := r.FormValue("role")
	if newRole == "" {
		http.Redirect(w, r, "/settings/users?error=Role is required", http.StatusSeeOther)
		return
	}

	// Get old roles for audit.
	rbacRepo := repository.NewRBACRepo(pool)
	oldRoles, _ := rbacRepo.GetUserRoles(r.Context(), userID)

	if err := h.auth.ChangeUserRole(r.Context(), userID, newRole, pool); err != nil {
		slog.Error("failed to change role", "error", err)
		http.Redirect(w, r, "/settings/users?error=Failed to change role", http.StatusSeeOther)
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	oldRoleNames := make([]string, 0, len(oldRoles))
	for _, r := range oldRoles {
		oldRoleNames = append(oldRoleNames, r.Name)
	}
	oldJSON := marshalAudit(map[string]any{"roles": oldRoleNames})
	newJSON := marshalAudit(map[string]any{"roles": []string{newRole}})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"update", "user", userID, oldJSON, newJSON, middleware.GetIPAddress(r))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/users?success=Role updated")
		return
	}
	http.Redirect(w, r, "/settings/users?success=Role updated", http.StatusSeeOther)
}

func (h *UserHandler) resetPassword(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	userIDStr := r.PathValue("id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	newPassword, err := h.auth.ResetPassword(r.Context(), userID)
	if err != nil {
		slog.Error("failed to reset password", "error", err)
		http.Redirect(w, r, "/settings/users?error=Failed to reset password", http.StatusSeeOther)
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	newJSON := marshalAudit(map[string]any{"action": "password_reset"})
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"update", "user", userID, nil, newJSON, middleware.GetIPAddress(r))

	successMsg := "Password reset. New password: " + newPassword
	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/users?success="+successMsg)
		return
	}
	http.Redirect(w, r, "/settings/users?success="+successMsg, http.StatusSeeOther)
}

func (h *UserHandler) removeUser(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())

	// Check for _method=DELETE.
	if r.FormValue("_method") != "DELETE" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userIDStr := r.PathValue("id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	currentUserID := middleware.GetUserID(r.Context())
	if userID == currentUserID {
		http.Redirect(w, r, "/settings/users?error=You cannot remove yourself", http.StatusSeeOther)
		return
	}

	orgID := middleware.GetOrgID(r.Context())

	// Get user info for audit before removing.
	userRepo := repository.NewUserRepo(h.platformPool)
	removedUser, _ := userRepo.GetByID(r.Context(), userID)

	if err := h.auth.RemoveUserFromOrg(r.Context(), userID, orgID, pool); err != nil {
		slog.Error("failed to remove user", "error", err)
		http.Redirect(w, r, "/settings/users?error=Failed to remove user", http.StatusSeeOther)
		return
	}

	// Log audit.
	auditRepo := repository.NewAuditRepo(pool)
	var oldJSON []byte
	if removedUser != nil {
		oldJSON = marshalAudit(map[string]any{"email": removedUser.Email, "full_name": removedUser.FullName})
	}
	auditRepo.Log(r.Context(), middleware.GetUserID(r.Context()), middleware.GetUserName(r.Context()),
		"delete", "user", userID, oldJSON, nil, middleware.GetIPAddress(r))

	if r.Header.Get("HX-Request") == "true" {
		w.Header().Set("HX-Redirect", "/settings/users?success=User removed")
		return
	}
	http.Redirect(w, r, "/settings/users?success=User removed", http.StatusSeeOther)
}

func (h *UserHandler) listRoles(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	rbacRepo := repository.NewRBACRepo(pool)

	roles, err := rbacRepo.ListRolesWithPermissions(r.Context())
	if err != nil {
		slog.Error("failed to list roles", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	data := map[string]any{
		"Title": "Roles & Permissions",
		"Roles": roles,
	}
	h.render.HTML(w, r, "roles.html", data)
}

func (h *UserHandler) showRole(w http.ResponseWriter, r *http.Request) {
	pool := middleware.TenantPool(r.Context())
	rbacRepo := repository.NewRBACRepo(pool)

	roleIDStr := r.PathValue("id")
	roleID, err := uuid.Parse(roleIDStr)
	if err != nil {
		http.Error(w, "Invalid role ID", http.StatusBadRequest)
		return
	}

	roles, err := rbacRepo.ListRoles(r.Context())
	if err != nil {
		slog.Error("failed to list roles", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	var role *model.Role
	for _, ro := range roles {
		if ro.ID == roleID {
			role = &ro
			break
		}
	}
	if role == nil {
		http.NotFound(w, r)
		return
	}

	perms, err := rbacRepo.GetRolePermissions(r.Context(), roleID)
	if err != nil {
		slog.Error("failed to get role permissions", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	data := map[string]any{
		"Title":       role.Name + " Role",
		"Role":        role,
		"Permissions": perms,
	}
	h.render.HTML(w, r, "role_detail.html", data)
}
