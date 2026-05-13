package model

import (
	"time"

	"github.com/google/uuid"
)

type Organization struct {
	ID             uuid.UUID `json:"id"`
	Name           string    `json:"name"`
	Slug           string    `json:"slug"`
	DBName         string    `json:"db_name"`
	CurrencyCode   string    `json:"currency_code"`
	CurrencySymbol string    `json:"currency_symbol"`
	LogoImageKey   string    `json:"logo_image_key"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type UserOrganization struct {
	UserID         uuid.UUID `json:"user_id"`
	OrganizationID uuid.UUID `json:"organization_id"`
	IsOwner        bool      `json:"is_owner"`
	CreatedAt      time.Time `json:"created_at"`
}
