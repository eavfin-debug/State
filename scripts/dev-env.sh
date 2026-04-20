#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PATH="$HOME/.cargo/bin:$ROOT_DIR/.tools/devenv/bin:$PATH"
# Use clang from local toolchain as Rust linker in this environment.
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$ROOT_DIR/.tools/devenv/bin/clang"

export PGDATA="$ROOT_DIR/.postgres/data"
export PGHOST="$ROOT_DIR/.postgres"
export PGPORT="5432"
export PGUSER="studytool"
export PGPASSWORD=""
export DATABASE_URL="postgresql://$PGUSER@localhost:$PGPORT/postgres?host=$PGHOST"
