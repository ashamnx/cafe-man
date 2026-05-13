# Searlo Cafe

Multi-tenant cafe management platform built with Go, HTMX, and PostgreSQL.

## Prerequisites

- Go 1.26+
- PostgreSQL

## Setup

```bash
cp .env.example .env
# Edit .env with your database credentials
```

## Development

```bash
make run
```

## Deployment

Hosted on DigitalOcean droplet at `178.128.208.168`, served at https://cafe.ashamnx.dev.

```bash
make deploy
```

This builds a linux/amd64 binary, uploads it to `/opt/searlo-cafe/`, and restarts the systemd service.

### Manual deploy steps

```bash
make build
ssh root@178.128.208.168 'systemctl stop searlo-cafe'
scp searlo-cafe root@178.128.208.168:/opt/searlo-cafe/searlo-cafe
ssh root@178.128.208.168 'chmod +x /opt/searlo-cafe/searlo-cafe && systemctl start searlo-cafe'
```

### Server details

- **Service:** `searlo-cafe.service`
- **Binary:** `/opt/searlo-cafe/searlo-cafe`
- **Config:** `/opt/searlo-cafe/.env`
- **Uploads:** `/opt/searlo-cafe/uploads/`
- **Nginx:** `/etc/nginx/sites-enabled/searlo-cafe`
- **SSL:** Certbot (auto-renews)
