# Railway Frappe HRMS Deployment Design

**Date:** 2026-08-29  
**Scope:** Full Frappe HRMS deployment on Railway for Paramveer0000/hrms. HRMS only; ERPNext is excluded.

## Goal

Deploy a complete, persistent Frappe HRMS environment on Railway. It must support normal Desk use, realtime features, background jobs, scheduled tasks, database persistence, and a custom domain after verification.

## Boundaries

- This is a multi-service deployment. A single Railway service is not sufficient.
- The `develop` branch remains the upstream-tracking branch.
- Railway-specific changes are isolated on `railway-hrms-deployment`.
- No database credential, administrator password, or Railway token is committed to Git.
- The existing Railway MariaDB and Redis services may be reused after their service-variable references are confirmed.
- ERPNext is not installed.

## Service Topology

| Service | Role | Persistent storage | Public |
|---|---|---:|---:|
| MariaDB | Frappe site database | Yes, `/var/lib/mysql` | No |
| Redis cache | cache and rate/session data | No | No |
| Redis queue | workers and Socket.IO queue | No | No |
| configurator | writes shared Frappe configuration; exits after success | Shared site volume | No |
| site-creator | creates/migrates HRMS site; exits after success | Shared site volume | No |
| backend | Gunicorn/Frappe API | Shared site volume | No |
| websocket | Socket.IO/realtime | Shared site volume | No |
| worker-short | default/short queues | Shared site volume | No |
| worker-long | long queue | Shared site volume | No |
| scheduler | scheduled jobs | Shared site volume | No |
| frontend | Nginx routes Desk/API/WebSocket traffic | Shared site assets/config | Yes |

A dedicated Redis cache and Redis queue instance are used rather than sending all traffic through one instance. MariaDB and every service that needs site assets share Railway persistent storage, with one writer at a time during initialization.

## Image and Application Strategy

A pinned Frappe production image will be built from the official Frappe Docker production pattern. The image installs the HRMS app from this fork’s deployment branch, pinned to the same compatible major Frappe version. No `latest` image tag is permitted.

The first deployment runs the configurator and site-creator jobs before the long-running services. Subsequent deployments run migrations before application processes accept traffic.

## Configuration and Data Flow

- Railway references (not raw secrets) supply MariaDB host, port, root password, Redis URLs, site name, and administrator password.
- Internal Railway networking is used for all backend dependencies.
- Only frontend receives a Railway public domain/custom domain.
- Frappe receives forwarded-proxy configuration and the public site hostname.
- The app service performs health checks only after the site exists and database migrations complete.

## Failure Handling

- A site creation failure must leave long-running services disabled; it cannot be masked by automatic restarts.
- Database/Redis connection failures surface in Railway logs and keep the dependant service unhealthy.
- Volumes and database are never deleted during application redeployments.
- Backups are enabled before real data is entered.

## Verification

1. Build the pinned image successfully.
2. Confirm configurator and site-creator complete once.
3. Open the Railway public domain and sign in as Administrator.
4. Create a test employee, leave type, and leave request.
5. Confirm a scheduled task/worker job is processed.
6. Confirm realtime WebSocket endpoint responds through frontend.
7. Confirm MariaDB data persists after a frontend redeploy.
8. Record the site URL and remove unused failed services.

## Non-goals

- Production HA, autoscaling, and load balancing.
- ERPNext accounting integration.
- Source-code customization beyond Railway deployment assets.
