# Railway HRMS

Create `redis-cache` and `redis-queue` services. Keep MariaDB and both Redis services private. Attach one volume to the HRMS runtime at `/home/frappe/frappe-bench/sites`.

Set `DB_HOST`, `DB_PORT`, `MARIADB_ROOT_PASSWORD`, `REDIS_CACHE_URL`, `REDIS_QUEUE_URL`, `SITE_NAME`, and a generated `ADMIN_PASSWORD` in Railway. Generate a public domain only on the HRMS runtime service; use its hostname as `SITE_NAME`.
