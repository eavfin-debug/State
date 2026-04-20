#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/dev-env.sh"

"$ROOT_DIR/.tools/devenv/bin/pg_ctl" -D "$PGDATA" stop -m fast
