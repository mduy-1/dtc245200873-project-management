#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/init.sh
docker info >/dev/null
docker compose config --quiet
docker compose up -d --build
docker compose ps
echo 'Website: http://localhost:8080 | Grafana: http://localhost:3000'
echo 'pgAdmin: http://localhost:5050 | Prometheus: http://localhost:9090'
