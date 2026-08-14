#!/usr/bin/env bash
# Developer entrypoint: merges docker-compose.yml with docker-compose.dev.yml
# so the ERPNext-LGM-Code repo mounts live into the running containers.
#
# Usage:
#   ./dev.sh up
#   ./dev.sh up -d
#   ./dev.sh down
#   ./dev.sh logs -f erpnext-python

set -euo pipefail

if [ ! -f .env ]; then
  echo "No .env found. Copy .env.example to .env and set PROD_REPO_PATH first."
  exit 1
fi

docker compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
