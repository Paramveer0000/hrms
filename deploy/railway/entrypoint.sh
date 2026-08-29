#!/usr/bin/env bash
set -euo pipefail
require_env(){ [ -n "${!1:-}" ] || { echo "Missing required variable: $1" >&2; exit 1; }; }
for v in DB_HOST DB_PORT MARIADB_ROOT_PASSWORD REDIS_CACHE_URL REDIS_QUEUE_URL SITE_NAME ADMIN_PASSWORD; do require_env "$v"; done
cd /home/frappe/frappe-bench
bench set-config -g db_host "$DB_HOST"
bench set-config -gp db_port "$DB_PORT"
bench set-config -g redis_cache "$REDIS_CACHE_URL"
bench set-config -g redis_queue "$REDIS_QUEUE_URL"
bench set-config -g redis_socketio "$REDIS_QUEUE_URL"
printf 'frappe\nhrms\n' > sites/apps.txt
if [ ! -d "sites/$SITE_NAME" ]; then
  bench new-site "$SITE_NAME" --mariadb-user-host-login-scope='%' --admin-password "$ADMIN_PASSWORD" --db-root-username root --db-root-password "$MARIADB_ROOT_PASSWORD" --install-app hrms --set-default
else
  bench --site "$SITE_NAME" migrate
fi
bench setup procfile
sed -i '/^redis_cache:/d; /^redis_queue:/d' Procfile
exec bench start
