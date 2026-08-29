# Railway Single-Runtime Amendment

The initial multi-runtime design has been superseded.

Railway volumes are service-scoped. Frappe’s shared sites directory therefore cannot be mounted by separate backend, worker, scheduler, WebSocket, and frontend services. The deployment uses one public HRMS runtime service with a single volume mounted at `/home/frappe/frappe-bench/sites`. Supervisor within that service runs Nginx, the backend, Socket.IO, workers, and scheduler.

MariaDB remains private with its own `/var/lib/mysql` volume. Redis cache and Redis queue remain private, separate services. Only the HRMS runtime service receives a Railway public domain.