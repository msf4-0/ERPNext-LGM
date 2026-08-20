#!/usr/bin/env bash
# Developer entrypoint: merges docker-compose.yml with docker-compose.dev.yml
# so the ERPNext-LGM-Code repo mounts live into the running containers.
#
# Usage:
#   ./dev.sh up
#   ./dev.sh up -d
#   ./dev.sh down
#   ./dev.sh logs -f erpnext-python
#   ./dev.sh setup

set -euo pipefail

SITE_NAME="custom-erpnext-nginx"
SERVICE="erpnext-python"
COMPOSE="docker compose -f docker-compose.yml -f docker-compose.dev.yml"

if [ ! -f .env ]; then
  echo "No .env found. Copy .env.example to .env and set PROD_REPO_PATH first."
  exit 1
fi

# Wait until the backend container can actually run bench commands against the
# site. Polls instead of a fixed sleep, since a fresh DB volume (after -v)
# takes noticeably longer to come up than a warm restart.
wait_for_backend() {
  echo "Waiting for backend and database to be ready..."
  local attempts=0
  local max_attempts=60  # ~2 minutes at 2s intervals

  until $COMPOSE exec -T -u frappe "$SERVICE" bench --site "$SITE_NAME" list-apps > /dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      echo "Backend did not become ready in time. Check 'docker compose logs $SERVICE'."
      exit 1
    fi
    sleep 2
  done
}

# Intercept a custom 'setup' command
if [ $# -gt 0 ] && [ "$1" = "setup" ]; then
  echo "Starting containers in the background..."
  $COMPOSE up -d

  wait_for_backend

  echo "Enabling Developer Mode..."
  $COMPOSE exec -T -u frappe "$SERVICE" bench set-config -g developer_mode 1

  echo "Running database migrations to pull in JSON changes..."
  $COMPOSE exec -T -u frappe "$SERVICE" bench --site "$SITE_NAME" migrate

  echo "Setup complete!"
  exit 0
fi

# Pass all other commands (up, down, logs) normally
$COMPOSE "$@"