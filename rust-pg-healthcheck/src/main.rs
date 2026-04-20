use std::{env, net::SocketAddr, sync::Arc};

use axum::{
    Json, Router,
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
};
use redis::AsyncCommands;
use serde::Serialize;
use tokio_postgres::NoTls;

#[derive(Clone)]
struct AppState {
    database_url: Arc<String>,
    redis_url: Arc<String>,
}

#[derive(Serialize)]
struct HealthResponse {
    status: &'static str,
    postgres: &'static str,
    redis: &'static str,
}

#[derive(Serialize)]
struct ErrorResponse {
    status: &'static str,
    message: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let host = env::var("APP_HOST").unwrap_or_else(|_| "0.0.0.0".to_owned());
    let port = env::var("APP_PORT")
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(8080);
    let database_url = env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://studytool@localhost:5432/studytool".to_owned());
    let redis_url = env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379".to_owned());

    let state = AppState {
        database_url: Arc::new(database_url),
        redis_url: Arc::new(redis_url),
    };

    let app = Router::new()
        .route("/", get(root))
        .route("/health", get(health))
        .with_state(state);

    let addr: SocketAddr = format!("{host}:{port}").parse()?;
    let listener = tokio::net::TcpListener::bind(addr).await?;

    println!("Listening on http://{addr}");
    axum::serve(listener, app).await?;
    Ok(())
}

async fn root() -> &'static str {
    "rust-pg-healthcheck is running"
}

async fn health(State(state): State<AppState>) -> Response {
    if let Err(error) = check_postgres(&state.database_url).await {
        return (
            StatusCode::SERVICE_UNAVAILABLE,
            Json(ErrorResponse {
                status: "error",
                message: format!("postgres check failed: {error}"),
            }),
        )
            .into_response();
    }

    if let Err(error) = check_redis(&state.redis_url).await {
        return (
            StatusCode::SERVICE_UNAVAILABLE,
            Json(ErrorResponse {
                status: "error",
                message: format!("redis check failed: {error}"),
            }),
        )
            .into_response();
    }

    (
        StatusCode::OK,
        Json(HealthResponse {
            status: "ok",
            postgres: "ok",
            redis: "ok",
        }),
    )
        .into_response()
}

async fn check_postgres(
    database_url: &str,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let (client, connection) = tokio_postgres::connect(database_url, NoTls).await?;

    tokio::spawn(async move {
        if let Err(error) = connection.await {
            eprintln!("postgres connection error: {error}");
        }
    });

    client.query_one("SELECT 1", &[]).await?;
    Ok(())
}

async fn check_redis(redis_url: &str) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let client = redis::Client::open(redis_url)?;
    let mut connection = client.get_multiplexed_async_connection().await?;
    let pong: String = connection.ping().await?;

    if pong != "PONG" {
        return Err(format!("unexpected redis response: {pong}").into());
    }

    Ok(())
}
