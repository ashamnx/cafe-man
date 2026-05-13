# Searlo Cafe

Multi-tenant cafe management platform. Go + HTMX + PostgreSQL (separate DB per tenant on DigitalOcean managed database).

## Build & Deploy

```bash
make deploy    # build, upload, restart
make build     # build only (linux/amd64)
make run       # run locally
```

### Production server
- **Host:** root@178.128.208.168
- **URL:** https://cafe.ashamnx.dev
- **App dir:** /opt/searlo-cafe/
- **Service:** searlo-cafe.service (systemd)
- **Nginx:** /etc/nginx/sites-enabled/searlo-cafe
- **SSL:** Certbot with auto-renewal

## Project Structure

- `cmd/server/main.go` - Entry point
- `internal/config/` - Env config loader
- `internal/database/` - Connection pools (platform + per-tenant)
- `internal/handler/` - HTTP handlers and templates
- `internal/middleware/` - Auth, RBAC, tenant injection, logging
- `internal/repository/` - Database queries
- `internal/service/` - Business logic (auth)
- `internal/model/` - Data models
- `internal/migrate/` - Embedded SQL migrations (run at startup)
- `internal/ai/` - Gemini bill scanner

## Key Patterns

- Multi-tenant: platform DB for users/orgs, separate tenant DB per org
- Templates use Go html/template with HTMX and Alpine.js
- Migrations are embedded and auto-run at startup
- Session-based auth with 24h lifetime
- RBAC per tenant database
