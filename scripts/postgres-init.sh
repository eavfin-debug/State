#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/dev-env.sh"

mkdir -p "$PGDATA" "$ROOT_DIR/.postgres/logs"

if [[ ! -f "$PGDATA/PG_VERSION" ]]; then
  "$ROOT_DIR/.tools/devenv/bin/initdb" -D "$PGDATA" -U "$PGUSER" -A trust --encoding=UTF8 --locale=C
fi

SOCKET_ESCAPED="${PGHOST//\//\\/}"

# Sandbox-friendly defaults: use unix socket directory and disable TCP listener.
if ! grep -q "^listen_addresses = ''" "$PGDATA/postgresql.conf"; then
  sed -i "s/^#listen_addresses =.*/listen_addresses = ''/" "$PGDATA/postgresql.conf"
fi
if ! grep -q "^unix_socket_directories = '$SOCKET_ESCAPED'" "$PGDATA/postgresql.conf"; then
  if grep -q "^#unix_socket_directories =" "$PGDATA/postgresql.conf"; then
    sed -i "s|^#unix_socket_directories =.*|unix_socket_directories = '$PGHOST'|" "$PGDATA/postgresql.conf"
  else
    echo "unix_socket_directories = '$PGHOST'" >> "$PGDATA/postgresql.conf"
  fi
fi
