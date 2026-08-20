:: Usage:
::   dev.cmd up
::   dev.cmd up -d
::   dev.cmd down
::   dev.cmd logs -f erpnext-python
::   dev.cmd setup

@echo off
setlocal enabledelayedexpansion

set SITE_NAME=custom-erpnext-nginx
set SERVICE=erpnext-python
set COMPOSE=docker compose -f docker-compose.yml -f docker-compose.dev.yml

if not exist .env (
    echo No .env found. Copy .env.example to .env and set PROD_REPO_PATH first.
    exit /b 1
)

:: Intercept a custom 'setup' command
if "%1"=="setup" (
    echo Starting containers in the background...
    %COMPOSE% up -d

    echo Waiting for backend and database to be ready...
    set ATTEMPTS=0

    :waitloop
    %COMPOSE% exec -T -u frappe %SERVICE% bench --site %SITE_NAME% list-apps >nul 2>&1
    if not errorlevel 1 goto backend_ready
    set /a ATTEMPTS+=1
    if !ATTEMPTS! GEQ 60 (
        echo Backend did not become ready in time. Check "docker compose logs %SERVICE%".
        exit /b 1
    )
    timeout /t 2 /nobreak >nul
    goto waitloop

    :backend_ready
    echo Enabling Developer Mode...
    %COMPOSE% exec -T -u frappe %SERVICE% bench set-config -g developer_mode 1

    echo Running database migrations to pull in JSON changes...
    %COMPOSE% exec -T -u frappe %SERVICE% bench --site %SITE_NAME% migrate

    echo Setup complete!
    exit /b 0
)

:: Pass all other commands (up, down, logs) normally
%COMPOSE% %*