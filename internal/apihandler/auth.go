package apihandler

import (
	"errors"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"
	"searlo-cafe/internal/service"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// OrgResponse is the API DTO for Organization, omitting the internal db_name field.
type OrgResponse struct {
	ID             uuid.UUID `json:"id"`
	Name           string    `json:"name"`
	Slug           string    `json:"slug"`
	CurrencyCode   string    `json:"currency_code"`
	CurrencySymbol string    `json:"currency_symbol"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
}

func orgToResponse(o model.Organization) OrgResponse {
	return OrgResponse{
		ID:             o.ID,
		Name:           o.Name,
		Slug:           o.Slug,
		CurrencyCode:   o.CurrencyCode,
		CurrencySymbol: o.CurrencySymbol,
		IsActive:       o.IsActive,
		CreatedAt:      o.CreatedAt,
	}
}

func orgsToResponse(orgs []model.Organization) []OrgResponse {
	out := make([]OrgResponse, len(orgs))
	for i, o := range orgs {
		out[i] = orgToResponse(o)
	}
	return out
}

type AuthAPIHandler struct {
	auth      *service.AuthService
	tokenRepo *repository.TokenRepo
	jwtSecret string
}

func NewAuthAPIHandler(auth *service.AuthService, platformPool *pgxpool.Pool, jwtSecret string) *AuthAPIHandler {
	return &AuthAPIHandler{
		auth:      auth,
		tokenRepo: repository.NewTokenRepo(platformPool),
		jwtSecret: jwtSecret,
	}
}

func (h *AuthAPIHandler) RegisterRoutes(mux *http.ServeMux, jwtMw func(http.Handler) http.Handler) {
	// Public routes (no JWT).
	mux.HandleFunc("POST /api/v1/auth/register", h.register)
	mux.HandleFunc("POST /api/v1/auth/login", h.login)
	mux.HandleFunc("POST /api/v1/auth/refresh", h.refresh)

	// Protected routes (JWT required).
	mux.Handle("POST /api/v1/auth/select-org", jwtMw(http.HandlerFunc(h.selectOrg)))
	mux.Handle("POST /api/v1/auth/logout", jwtMw(http.HandlerFunc(h.logout)))
	mux.Handle("GET /api/v1/auth/me", jwtMw(http.HandlerFunc(h.me)))
}

type registerRequest struct {
	Email          string `json:"email"`
	Password       string `json:"password"`
	FullName       string `json:"full_name"`
	OrgName        string `json:"org_name"`
	CurrencyCode   string `json:"currency_code"`
	CurrencySymbol string `json:"currency_symbol"`
}

func (h *AuthAPIHandler) register(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	req.FullName = strings.TrimSpace(req.FullName)
	req.OrgName = strings.TrimSpace(req.OrgName)

	if req.Email == "" || req.Password == "" || req.FullName == "" || req.OrgName == "" {
		writeError(w, http.StatusBadRequest, "email, password, full_name, and org_name are required")
		return
	}

	if len(req.Password) < 8 {
		writeError(w, http.StatusBadRequest, "password must be at least 8 characters")
		return
	}

	result, err := h.auth.Register(r.Context(), service.RegisterInput{
		Email:          req.Email,
		Password:       req.Password,
		FullName:       req.FullName,
		OrgName:        req.OrgName,
		CurrencyCode:   req.CurrencyCode,
		CurrencySymbol: req.CurrencySymbol,
	})
	if err != nil {
		switch {
		case errors.Is(err, service.ErrEmailTaken):
			writeError(w, http.StatusConflict, "email already registered")
		case errors.Is(err, service.ErrOrgSlugTaken):
			writeError(w, http.StatusConflict, "organization name already taken")
		default:
			slog.Error("registration failed", "error", err)
			writeError(w, http.StatusInternalServerError, "registration failed")
		}
		return
	}

	// Generate tokens with org already selected (register creates one org).
	accessToken, err := service.GenerateAccessToken(result.User.ID, &result.Org.ID, result.Org.DBName, result.User.FullName, h.jwtSecret)
	if err != nil {
		slog.Error("failed to generate access token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	refreshRaw, refreshHash, err := service.GenerateRefreshToken()
	if err != nil {
		slog.Error("failed to generate refresh token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	if err := h.tokenRepo.Create(r.Context(), result.User.ID, refreshHash, time.Now().Add(service.RefreshTokenExpiry)); err != nil {
		slog.Error("failed to store refresh token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{
		"user":          result.User,
		"org":           orgToResponse(*result.Org),
		"access_token":  accessToken,
		"refresh_token": refreshRaw,
	})
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *AuthAPIHandler) login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "email and password are required")
		return
	}

	user, err := h.auth.Login(r.Context(), req.Email, req.Password)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidCredentials):
			writeError(w, http.StatusUnauthorized, "invalid email or password")
		case errors.Is(err, service.ErrAccountDisabled):
			writeError(w, http.StatusForbidden, "account is disabled")
		default:
			slog.Error("login failed", "error", err)
			writeError(w, http.StatusInternalServerError, "login failed")
		}
		return
	}

	orgs, err := h.auth.GetUserOrgs(r.Context(), user.ID)
	if err != nil {
		slog.Error("failed to get user orgs", "error", err)
		writeError(w, http.StatusInternalServerError, "login failed")
		return
	}

	// If single org, generate token with org pre-selected.
	var accessToken string
	if len(orgs) == 1 {
		accessToken, err = service.GenerateAccessToken(user.ID, &orgs[0].ID, orgs[0].DBName, user.FullName, h.jwtSecret)
	} else {
		accessToken, err = service.GenerateAccessToken(user.ID, nil, "", user.FullName, h.jwtSecret)
	}
	if err != nil {
		slog.Error("failed to generate access token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	refreshRaw, refreshHash, err := service.GenerateRefreshToken()
	if err != nil {
		slog.Error("failed to generate refresh token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	if err := h.tokenRepo.Create(r.Context(), user.ID, refreshHash, time.Now().Add(service.RefreshTokenExpiry)); err != nil {
		slog.Error("failed to store refresh token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to generate token")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"user":          user,
		"orgs":          orgsToResponse(orgs),
		"access_token":  accessToken,
		"refresh_token": refreshRaw,
	})
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func (h *AuthAPIHandler) refresh(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.RefreshToken == "" {
		writeError(w, http.StatusBadRequest, "refresh_token is required")
		return
	}

	tokenHash := service.HashToken(req.RefreshToken)
	stored, err := h.tokenRepo.GetByHash(r.Context(), tokenHash)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "invalid refresh token")
		return
	}

	if stored.ExpiresAt.Before(time.Now()) {
		h.tokenRepo.DeleteByHash(r.Context(), tokenHash)
		writeError(w, http.StatusUnauthorized, "refresh token expired")
		return
	}

	// Look up user for name and orgs for auto-select.
	refreshUser, err := h.auth.GetUser(r.Context(), stored.UserID)
	if err != nil {
		slog.Error("failed to get user", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to refresh token")
		return
	}

	orgs, err := h.auth.GetUserOrgs(r.Context(), stored.UserID)
	if err != nil {
		slog.Error("failed to get user orgs", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to refresh token")
		return
	}

	var accessToken string
	if len(orgs) == 1 {
		accessToken, err = service.GenerateAccessToken(stored.UserID, &orgs[0].ID, orgs[0].DBName, refreshUser.FullName, h.jwtSecret)
	} else {
		accessToken, err = service.GenerateAccessToken(stored.UserID, nil, "", refreshUser.FullName, h.jwtSecret)
	}
	if err != nil {
		slog.Error("failed to generate access token", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to refresh token")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"access_token": accessToken,
	})
}

type selectOrgRequest struct {
	OrgID string `json:"org_id"`
}

func (h *AuthAPIHandler) selectOrg(w http.ResponseWriter, r *http.Request) {
	var req selectOrgRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.OrgID == "" {
		writeError(w, http.StatusBadRequest, "org_id is required")
		return
	}

	userID := middleware.GetUserID(r.Context())
	userName := middleware.GetUserName(r.Context())
	orgs, err := h.auth.GetUserOrgs(r.Context(), userID)
	if err != nil {
		slog.Error("failed to get user orgs", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to select organization")
		return
	}

	for _, org := range orgs {
		if org.ID.String() == req.OrgID {
			accessToken, err := service.GenerateAccessToken(userID, &org.ID, org.DBName, userName, h.jwtSecret)
			if err != nil {
				slog.Error("failed to generate access token", "error", err)
				writeError(w, http.StatusInternalServerError, "failed to generate token")
				return
			}

			writeJSON(w, http.StatusOK, map[string]any{
				"org":          orgToResponse(org),
				"access_token": accessToken,
			})
			return
		}
	}

	writeError(w, http.StatusForbidden, "you don't have access to this organization")
}

func (h *AuthAPIHandler) logout(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest
	if err := readJSON(r, &req); err != nil || req.RefreshToken == "" {
		// Even if no refresh token provided, just return success.
		writeJSON(w, http.StatusOK, map[string]string{"message": "logged out"})
		return
	}

	tokenHash := service.HashToken(req.RefreshToken)
	h.tokenRepo.DeleteByHash(r.Context(), tokenHash)

	writeJSON(w, http.StatusOK, map[string]string{"message": "logged out"})
}

func (h *AuthAPIHandler) me(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	orgs, err := h.auth.GetUserOrgs(r.Context(), userID)
	if err != nil {
		slog.Error("failed to get user orgs", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to get user info")
		return
	}

	// Find user details from the orgs query isn't possible directly;
	// we need the user repo. Use platform pool via token repo's pool.
	user, err := h.auth.GetUser(r.Context(), userID)
	if err != nil {
		slog.Error("failed to get user", "error", err)
		writeError(w, http.StatusInternalServerError, "failed to get user info")
		return
	}

	orgID := middleware.GetOrgID(r.Context())
	var selectedOrg *OrgResponse
	for _, o := range orgs {
		if o.ID == orgID {
			resp := orgToResponse(o)
			selectedOrg = &resp
			break
		}
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"user":         user,
		"orgs":         orgsToResponse(orgs),
		"selected_org": selectedOrg,
	})
}
