#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <db_name>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/dev-env.sh"

"$ROOT_DIR/.tools/devenv/bin/createdb" -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$1"
