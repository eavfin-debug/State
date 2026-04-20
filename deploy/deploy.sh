#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$DEPLOY_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

required_vars=(
  APP_IMAGE
  APP_DOMAIN
  LETSENCRYPT_EMAIL
  DATABASE_URL
  REDIS_PASSWORD
  GHCR_USERNAME
  GHCR_TOKEN
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Required variable $var_name is empty" >&2
    exit 1
  fi
done

mkdir -p "$DEPLOY_DIR/caddy_data" "$DEPLOY_DIR/caddy_config"

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
docker compose --env-file "$ENV_FILE" -f "$DEPLOY_DIR/docker-compose.yml" pull
docker compose --env-file "$ENV_FILE" -f "$DEPLOY_DIR/docker-compose.yml" up -d --remove-orphans
docker image prune -f
