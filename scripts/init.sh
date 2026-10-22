#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -e .env ]]; then
  echo '.env already exists; keeping current passwords.'
  exit 0
fi
command -v openssl >/dev/null || { echo 'Install openssl first.' >&2; exit 1; }
umask 077
for name in POSTGRES_PASSWORD APP_DB_PASSWORD MONITOR_DB_PASSWORD PGADMIN_PASSWORD GRAFANA_PASSWORD; do
  printf '%s=%s\n' "$name" "$(openssl rand -hex 32)"
done > .env
printf 'PGADMIN_EMAIL=student@example.com\n' >> .env
echo 'Created .env. Do not commit or share it.'
