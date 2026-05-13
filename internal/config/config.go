package config

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type Config struct {
	DatabaseURL       string
	TenantDatabaseURL string
	SessionSecret     string
	ListenAddr        string
	UploadDir         string
	GeminiAPIKey      string

	DOSpacesKey      string
	DOSpacesSecret   string
	DOSpacesEndpoint string
	DOSpacesBucket   string
	DOSpacesPrefix   string
	DOSpacesCDNURL   string

	JWTSecret string
}

func Load() (*Config, error) {
	loadDotEnv(".env")

	cfg := &Config{
		DatabaseURL:       os.Getenv("DATABASE_URL"),
		TenantDatabaseURL: os.Getenv("TENANT_DATABASE_URL"),
		SessionSecret:     os.Getenv("SESSION_SECRET"),
		ListenAddr:        os.Getenv("LISTEN_ADDR"),
		UploadDir:         os.Getenv("UPLOAD_DIR"),
		GeminiAPIKey:      os.Getenv("GEMINI_API_KEY"),

		DOSpacesKey:      os.Getenv("DO_SPACES_KEY"),
		DOSpacesSecret:   os.Getenv("DO_SPACES_SECRET"),
		DOSpacesEndpoint: os.Getenv("DO_SPACES_ENDPOINT"),
		DOSpacesBucket:   os.Getenv("DO_SPACES_BUCKET"),
		DOSpacesPrefix:   os.Getenv("DO_SPACES_PREFIX"),
		DOSpacesCDNURL:   os.Getenv("DO_SPACES_CDN_URL"),

		JWTSecret: os.Getenv("JWT_SECRET"),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}
	if cfg.SessionSecret == "" {
		return nil, fmt.Errorf("SESSION_SECRET is required")
	}
	if cfg.ListenAddr == "" {
		cfg.ListenAddr = ":8080"
	}
	if cfg.TenantDatabaseURL == "" {
		cfg.TenantDatabaseURL = cfg.DatabaseURL
	}
	if cfg.UploadDir == "" {
		cfg.UploadDir = "./uploads"
	}

	return cfg, nil
}

func loadDotEnv(path string) {
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, val, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		key = strings.TrimSpace(key)
		val = strings.TrimSpace(val)
		if os.Getenv(key) == "" {
			os.Setenv(key, val)
		}
	}
}
