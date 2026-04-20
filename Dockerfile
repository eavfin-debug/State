FROM rust:1.87-slim-bookworm AS builder

WORKDIR /app
COPY rust-pg-healthcheck/Cargo.toml rust-pg-healthcheck/Cargo.lock ./rust-pg-healthcheck/
COPY rust-pg-healthcheck/src ./rust-pg-healthcheck/src

WORKDIR /app/rust-pg-healthcheck
RUN cargo build --release

FROM debian:bookworm-slim

RUN useradd --create-home --uid 10001 appuser

COPY --from=builder /app/rust-pg-healthcheck/target/release/rust-pg-healthcheck /usr/local/bin/rust-pg-healthcheck

ENV APP_HOST=0.0.0.0
ENV APP_PORT=8080

EXPOSE 8080
USER appuser

ENTRYPOINT ["/usr/local/bin/rust-pg-healthcheck"]
