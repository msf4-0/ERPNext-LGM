@echo off
if not exist .env (
    echo No .env found. Copy .env.example to .env and set PROD_REPO_PATH first.
    exit /b 1
)
docker compose -f docker-compose.yml -f docker-compose.dev.yml %*