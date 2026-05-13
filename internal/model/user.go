package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID                uuid.UUID `json:"id"`
	Email             string    `json:"email"`
	PasswordHash      string    `json:"-"`
	FullName          string    `json:"full_name"`
	IsActive          bool      `json:"is_active"`
	MustResetPassword bool      `json:"must_reset_password"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// OrgMember represents a user within an organization with their role info.
type OrgMember struct {
	UserID   uuid.UUID `json:"user_id"`
	Email    string    `json:"email"`
	FullName string    `json:"full_name"`
	IsActive bool      `json:"is_active"`
	IsOwner  bool      `json:"is_owner"`
	Roles    []Role    `json:"roles"`
	JoinedAt time.Time `json:"joined_at"`
}
