# Rust + PostgreSQL Infrastructure

## Installed locally (no root)

- Rust toolchain: `rustc`, `cargo`, `rustup` via `~/.cargo`.
- Build toolchain in project: `clang`, `lld`, `make`, `pkg-config` in `.tools/devenv`.
- PostgreSQL 18.3 binaries in `.tools/devenv`.
- PostgreSQL data directory: `.postgres/data`.
- PostgreSQL logs: `.postgres/logs/postgres.log`.

## Quick start

From project root:

```bash
source scripts/dev-env.sh
```

### Rust check

```bash
cargo new hello_rust --bin
cd hello_rust
cargo run
```

### PostgreSQL commands

```bash
scripts/postgres-init.sh
scripts/postgres-start.sh
scripts/postgres-status.sh
scripts/postgres-create-db.sh app_db
scripts/postgres-stop.sh
```

### psql connect

```bash
source scripts/dev-env.sh
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres
```

## Notes

- In this execution environment, sandbox mode blocks socket creation. If DB start fails inside sandbox, run start/status commands with elevated execution mode.
- Workspace rust linker is configured in `.cargo/config.toml`.
