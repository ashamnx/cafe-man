package service

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"regexp"
	"strings"

	"searlo-cafe/internal/database"
	"searlo-cafe/internal/migrate"
	"searlo-cafe/internal/model"
	"searlo-cafe/internal/repository"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrEmailTaken         = errors.New("email already registered")
	ErrOrgSlugTaken       = errors.New("organization slug already taken")
	ErrAccountDisabled    = errors.New("account is disabled")
	ErrAlreadyInOrg       = errors.New("user is already in this organization")
	ErrCannotRemoveSelf   = errors.New("cannot remove yourself from the organization")
)

var slugRegex = regexp.MustCompile(`[^a-z0-9]+`)

type AuthService struct {
	platformPool *pgxpool.Pool
	userRepo     *repository.UserRepo
	orgRepo      *repository.OrganizationRepo
	tenants      *database.TenantManager
}

func NewAuthService(platformPool *pgxpool.Pool, userRepo *repository.UserRepo, orgRepo *repository.OrganizationRepo, tenants *database.TenantManager) *AuthService {
	return &AuthService{
		platformPool: platformPool,
		userRepo:     userRepo,
		orgRepo:      orgRepo,
		tenants:      tenants,
	}
}

type RegisterInput struct {
	Email          string
	Password       string
	FullName       string
	OrgName        string
	CurrencyCode   string
	CurrencySymbol string
}

type RegisterResult struct {
	User *model.User
	Org  *model.Organization
}

func (s *AuthService) Register(ctx context.Context, input RegisterInput) (*RegisterResult, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("hash password: %w", err)
	}

	user, err := s.userRepo.Create(ctx, input.Email, string(hash), input.FullName)
	if errors.Is(err, repository.ErrDuplicate) {
		return nil, ErrEmailTaken
	}
	if err != nil {
		return nil, fmt.Errorf("create user: %w", err)
	}

	slug := generateSlug(input.OrgName)
	dbName := "tenant_" + strings.ReplaceAll(slug, "-", "_")

	if input.CurrencyCode == "" {
		input.CurrencyCode = "MVR"
	}
	if input.CurrencySymbol == "" {
		input.CurrencySymbol = "Mvr"
	}

	org, err := s.orgRepo.Create(ctx, input.OrgName, slug, dbName, input.CurrencyCode, input.CurrencySymbol)
	if errors.Is(err, repository.ErrDuplicate) {
		return nil, ErrOrgSlugTaken
	}
	if err != nil {
		return nil, fmt.Errorf("create organization: %w", err)
	}

	if err := s.orgRepo.AddUser(ctx, user.ID, org.ID, true); err != nil {
		return nil, fmt.Errorf("add user to org: %w", err)
	}

	// Create tenant database.
	if err := s.tenants.CreateDatabase(ctx, s.platformPool, dbName); err != nil {
		return nil, fmt.Errorf("create tenant database: %w", err)
	}

	// Run tenant migrations.
	tenantPool, err := s.tenants.Pool(ctx, dbName)
	if err != nil {
		return nil, fmt.Errorf("connect to tenant db: %w", err)
	}
	if err := migrate.RunTenant(ctx, tenantPool); err != nil {
		return nil, fmt.Errorf("run tenant migrations: %w", err)
	}

	// Assign owner role to user in tenant DB.
	rbacRepo := repository.NewRBACRepo(tenantPool)
	ownerRole, err := rbacRepo.GetRoleByName(ctx, "owner")
	if err != nil {
		return nil, fmt.Errorf("get owner role: %w", err)
	}
	if err := rbacRepo.AssignRole(ctx, user.ID, ownerRole.ID); err != nil {
		return nil, fmt.Errorf("assign owner role: %w", err)
	}

	return &RegisterResult{User: user, Org: org}, nil
}

func (s *AuthService) Login(ctx context.Context, email, password string) (*model.User, error) {
	user, err := s.userRepo.GetByEmail(ctx, email)
	if errors.Is(err, repository.ErrNotFound) {
		return nil, ErrInvalidCredentials
	}
	if err != nil {
		return nil, fmt.Errorf("get user: %w", err)
	}

	if !user.IsActive {
		return nil, ErrAccountDisabled
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	return user, nil
}

func (s *AuthService) GetUserOrgs(ctx context.Context, userID uuid.UUID) ([]model.Organization, error) {
	return s.orgRepo.GetUserOrgs(ctx, userID)
}

func (s *AuthService) GetUser(ctx context.Context, userID uuid.UUID) (*model.User, error) {
	return s.userRepo.GetByID(ctx, userID)
}

type InviteInput struct {
	Email    string
	FullName string
	OrgID    uuid.UUID
	RoleName string
}

// InviteUser adds a user to an organization. If the user doesn't exist, creates them with a temp password.
func (s *AuthService) InviteUser(ctx context.Context, input InviteInput, tenantPool *pgxpool.Pool) (*model.User, string, error) {
	// Check if user already exists.
	user, err := s.userRepo.GetByEmail(ctx, input.Email)
	tempPassword := ""

	if errors.Is(err, repository.ErrNotFound) {
		// Create new user with temp password.
		tempPassword = generateTempPassword()
		hash, err := bcrypt.GenerateFromPassword([]byte(tempPassword), bcrypt.DefaultCost)
		if err != nil {
			return nil, "", fmt.Errorf("hash password: %w", err)
		}
		user, err = s.userRepo.CreateWithTempPassword(ctx, input.Email, string(hash), input.FullName)
		if err != nil {
			return nil, "", fmt.Errorf("create user: %w", err)
		}
	} else if err != nil {
		return nil, "", fmt.Errorf("get user: %w", err)
	}

	// Check if already in org.
	inOrg, err := s.orgRepo.IsUserInOrg(ctx, user.ID, input.OrgID)
	if err != nil {
		return nil, "", fmt.Errorf("check org membership: %w", err)
	}
	if inOrg {
		return nil, "", ErrAlreadyInOrg
	}

	// Add to organization.
	if err := s.orgRepo.AddUser(ctx, user.ID, input.OrgID, false); err != nil {
		return nil, "", fmt.Errorf("add user to org: %w", err)
	}

	// Assign role in tenant DB.
	rbacRepo := repository.NewRBACRepo(tenantPool)
	role, err := rbacRepo.GetRoleByName(ctx, input.RoleName)
	if err != nil {
		return nil, "", fmt.Errorf("get role %q: %w", input.RoleName, err)
	}
	if err := rbacRepo.AssignRole(ctx, user.ID, role.ID); err != nil {
		return nil, "", fmt.Errorf("assign role: %w", err)
	}

	return user, tempPassword, nil
}

// ChangeUserRole removes all existing roles and assigns the new one.
func (s *AuthService) ChangeUserRole(ctx context.Context, userID uuid.UUID, newRoleName string, tenantPool *pgxpool.Pool) error {
	rbacRepo := repository.NewRBACRepo(tenantPool)

	role, err := rbacRepo.GetRoleByName(ctx, newRoleName)
	if err != nil {
		return fmt.Errorf("get role %q: %w", newRoleName, err)
	}

	if err := rbacRepo.RemoveUserRoles(ctx, userID); err != nil {
		return fmt.Errorf("remove existing roles: %w", err)
	}

	if err := rbacRepo.AssignRole(ctx, userID, role.ID); err != nil {
		return fmt.Errorf("assign new role: %w", err)
	}

	return nil
}

// RemoveUserFromOrg removes a user from an organization and their tenant roles.
func (s *AuthService) RemoveUserFromOrg(ctx context.Context, userID, orgID uuid.UUID, tenantPool *pgxpool.Pool) error {
	// Remove tenant roles.
	rbacRepo := repository.NewRBACRepo(tenantPool)
	if err := rbacRepo.RemoveUserRoles(ctx, userID); err != nil {
		return fmt.Errorf("remove user roles: %w", err)
	}

	// Remove from organization.
	if err := s.orgRepo.RemoveUser(ctx, userID, orgID); err != nil {
		return fmt.Errorf("remove user from org: %w", err)
	}

	return nil
}

// ResetPassword generates a new temporary password for a user.
func (s *AuthService) ResetPassword(ctx context.Context, userID uuid.UUID) (string, error) {
	tempPassword := generateTempPassword()
	hash, err := bcrypt.GenerateFromPassword([]byte(tempPassword), bcrypt.DefaultCost)
	if err != nil {
		return "", fmt.Errorf("hash password: %w", err)
	}

	if err := s.userRepo.UpdatePassword(ctx, userID, string(hash)); err != nil {
		return "", fmt.Errorf("update password: %w", err)
	}

	return tempPassword, nil
}

func generateTempPassword() string {
	const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$"
	b := make([]byte, 16)
	for i := range b {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(chars))))
		b[i] = chars[n.Int64()]
	}
	return string(b)
}

func generateSlug(name string) string {
	slug := strings.ToLower(strings.TrimSpace(name))
	slug = slugRegex.ReplaceAllString(slug, "-")
	slug = strings.Trim(slug, "-")
	if slug == "" {
		slug = "org"
	}
	return slug
}
