# Automatic Deployment via GitHub Actions

This project is prepared for automatic production deployment after every push to `main`.

## What gets deployed

- Rust application in Docker, published to `ghcr.io`.
- Caddy in Docker as the public reverse proxy with automatic TLS.
- Redis in Docker with a password and persistent volume.
- PostgreSQL stays outside Docker and is reached through `DATABASE_URL`.

## Repository files added for deployment

- `.github/workflows/deploy.yml`
- `Dockerfile`
- `.dockerignore`
- `.gitignore`
- `deploy/docker-compose.yml`
- `deploy/Caddyfile`
- `deploy/deploy.sh`
- `deploy/.env.example`

## One-time server requirements

Install these on the Linux server before the first deploy:

1. Docker Engine
2. Docker Compose plugin (`docker compose`)
3. A native PostgreSQL instance reachable from Docker containers via `host.docker.internal` or another host-accessible address
4. DNS `A` record for `APP_DOMAIN` pointing to the server IP
5. Open inbound ports `80` and `443`

## GitHub repository secrets

Add these secrets in the private GitHub repository:

- `SERVER_HOST`: public IP or DNS of the Linux server
- `SERVER_PORT`: SSH port, usually `22`
- `SERVER_USER`: Linux user with permission to run Docker
- `SERVER_SSH_KEY`: private SSH key used by GitHub Actions
- `SERVER_DEPLOY_PATH`: deployment directory on server, for example `/opt/state-app`
- `APP_DOMAIN`: domain served by Caddy, for example `api.example.com`
- `LETSENCRYPT_EMAIL`: email for TLS certificates
- `DATABASE_URL`: PostgreSQL connection string to the native server database
- `REDIS_PASSWORD`: strong Redis password
- `GHCR_USERNAME`: GitHub username or machine user allowed to pull the private package
- `GHCR_TOKEN`: token with `read:packages` for GHCR pull on the server

## First deploy flow

1. Push this repository to GitHub.
2. Add all repository secrets listed above.
3. Make sure the server user can run `docker compose`.
4. Push to `main` or run the workflow manually.

The workflow will:

1. build the Rust image
2. push it to GHCR
3. upload deployment files to the server
4. update `.env` on the server
5. run `deploy.sh`
6. pull fresh app, Caddy, and Redis images
7. recreate the containers

## Notes

- The current local notes mention a Windows host, but this deployment setup targets Linux only.
- `DATABASE_URL` should usually use `host.docker.internal` rather than `127.0.0.1`, because the Rust app runs inside Docker.
- PostgreSQL must allow connections from the Docker bridge network in both `postgresql.conf` and `pg_hba.conf`.
- If PostgreSQL requires SSL or a non-default host, put the exact production string into `DATABASE_URL`.
