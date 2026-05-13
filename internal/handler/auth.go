package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"strings"

	"searlo-cafe/internal/middleware"
	"searlo-cafe/internal/service"

	"github.com/alexedwards/scs/v2"
)

type AuthHandler struct {
	auth     *service.AuthService
	sessions *scs.SessionManager
	render   *Renderer
}

func NewAuthHandler(auth *service.AuthService, sessions *scs.SessionManager, render *Renderer) *AuthHandler {
	return &AuthHandler{auth: auth, sessions: sessions, render: render}
}

func (h *AuthHandler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /register", h.showRegister)
	mux.HandleFunc("POST /register", h.handleRegister)
	mux.HandleFunc("GET /login", h.showLogin)
	mux.HandleFunc("POST /login", h.handleLogin)
	mux.HandleFunc("POST /logout", h.handleLogout)
	mux.HandleFunc("GET /select-org", h.showSelectOrg)
	mux.HandleFunc("POST /select-org", h.handleSelectOrg)
}

func (h *AuthHandler) showRegister(w http.ResponseWriter, r *http.Request) {
	h.render.HTML(w, r, "register.html", nil)
}

func (h *AuthHandler) handleRegister(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		h.render.HTML(w, r, "register.html", map[string]any{"Error": "Invalid form data"})
		return
	}

	input := service.RegisterInput{
		Email:          strings.TrimSpace(r.FormValue("email")),
		Password:       r.FormValue("password"),
		FullName:       strings.TrimSpace(r.FormValue("full_name")),
		OrgName:        strings.TrimSpace(r.FormValue("org_name")),
		CurrencyCode:   strings.TrimSpace(r.FormValue("currency_code")),
		CurrencySymbol: strings.TrimSpace(r.FormValue("currency_symbol")),
	}

	if input.Email == "" || input.Password == "" || input.FullName == "" || input.OrgName == "" {
		h.render.HTML(w, r, "register.html", map[string]any{
			"Error": "All fields are required",
			"Input": input,
		})
		return
	}

	if len(input.Password) < 8 {
		h.render.HTML(w, r, "register.html", map[string]any{
			"Error": "Password must be at least 8 characters",
			"Input": input,
		})
		return
	}

	result, err := h.auth.Register(r.Context(), input)
	if err != nil {
		msg := "Registration failed"
		if errors.Is(err, service.ErrEmailTaken) {
			msg = "Email already registered"
		} else if errors.Is(err, service.ErrOrgSlugTaken) {
			msg = "Organization name already taken"
		} else {
			slog.Error("registration failed", "error", err)
		}
		h.render.HTML(w, r, "register.html", map[string]any{"Error": msg, "Input": input})
		return
	}

	// Set session.
	h.sessions.Put(r.Context(), "user_id", result.User.ID.String())
	h.sessions.Put(r.Context(), "org_id", result.Org.ID.String())
	h.sessions.Put(r.Context(), "org_db", result.Org.DBName)
	h.sessions.Put(r.Context(), "user_name", result.User.FullName)
	h.sessions.Put(r.Context(), "org_name", result.Org.Name)
	h.sessions.Put(r.Context(), "org_logo_key", result.Org.LogoImageKey)
	h.sessions.Put(r.Context(), "org_slug", result.Org.Slug)
	h.sessions.Put(r.Context(), "org_currency_symbol", result.Org.CurrencySymbol)

	http.Redirect(w, r, "/dashboard", http.StatusSeeOther)
}

func (h *AuthHandler) showLogin(w http.ResponseWriter, r *http.Request) {
	h.render.HTML(w, r, "login.html", nil)
}

func (h *AuthHandler) handleLogin(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		h.render.HTML(w, r, "login.html", map[string]any{"Error": "Invalid form data"})
		return
	}

	email := strings.TrimSpace(r.FormValue("email"))
	password := r.FormValue("password")

	user, err := h.auth.Login(r.Context(), email, password)
	if err != nil {
		msg := "Invalid email or password"
		if errors.Is(err, service.ErrAccountDisabled) {
			msg = "Account is disabled"
		}
		h.render.HTML(w, r, "login.html", map[string]any{"Error": msg, "Email": email})
		return
	}

	h.sessions.Put(r.Context(), "user_id", user.ID.String())
	h.sessions.Put(r.Context(), "user_name", user.FullName)

	// Check how many orgs the user belongs to.
	orgs, err := h.auth.GetUserOrgs(r.Context(), user.ID)
	if err != nil {
		slog.Error("failed to get user orgs", "error", err)
		h.render.HTML(w, r, "login.html", map[string]any{"Error": "Login failed"})
		return
	}

	if len(orgs) == 1 {
		h.sessions.Put(r.Context(), "org_id", orgs[0].ID.String())
		h.sessions.Put(r.Context(), "org_db", orgs[0].DBName)
		h.sessions.Put(r.Context(), "org_name", orgs[0].Name)
		h.sessions.Put(r.Context(), "org_logo_key", orgs[0].LogoImageKey)
		h.sessions.Put(r.Context(), "org_slug", orgs[0].Slug)
		h.sessions.Put(r.Context(), "org_currency_symbol", orgs[0].CurrencySymbol)
		http.Redirect(w, r, "/dashboard", http.StatusSeeOther)
		return
	}

	http.Redirect(w, r, "/select-org", http.StatusSeeOther)
}

func (h *AuthHandler) handleLogout(w http.ResponseWriter, r *http.Request) {
	h.sessions.Destroy(r.Context())
	http.Redirect(w, r, "/login", http.StatusSeeOther)
}

func (h *AuthHandler) showSelectOrg(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	orgs, err := h.auth.GetUserOrgs(r.Context(), userID)
	if err != nil {
		slog.Error("failed to get orgs", "error", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	h.render.HTML(w, r, "select_org.html", map[string]any{"Orgs": orgs})
}

func (h *AuthHandler) handleSelectOrg(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form", http.StatusBadRequest)
		return
	}

	orgID := r.FormValue("org_id")
	userID := middleware.GetUserID(r.Context())

	orgs, err := h.auth.GetUserOrgs(r.Context(), userID)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	for _, org := range orgs {
		if org.ID.String() == orgID {
			h.sessions.Put(r.Context(), "org_id", org.ID.String())
			h.sessions.Put(r.Context(), "org_db", org.DBName)
			h.sessions.Put(r.Context(), "org_name", org.Name)
			h.sessions.Put(r.Context(), "org_logo_key", org.LogoImageKey)
			h.sessions.Put(r.Context(), "org_slug", org.Slug)
			h.sessions.Put(r.Context(), "org_currency_symbol", org.CurrencySymbol)
			http.Redirect(w, r, "/dashboard", http.StatusSeeOther)
			return
		}
	}

	http.Error(w, "Invalid organization", http.StatusForbidden)
}
