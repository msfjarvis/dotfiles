# BookOrbit NixOS module

Decision: run BookOrbit as an OCI application container backed by native NixOS PostgreSQL plus pgvector, with passwordless local peer authentication over a Unix socket.

- Effective upstream deployment input: root `docker-compose.yml` and `.env.example`; the app mounts `/books` and `/data`, exposes port 3000, and requires `uuid-ossp`, `pg_trgm`, and `vector`.
- Preserve the container for the app. Its administrator-supplied dotenv file contains application secrets (`JWT_SECRET` and `SETUP_BOOTSTRAP_TOKEN`), but database access is configured entirely by `DATABASE_URL` and does not require a database secret.
- Mount host `/run/postgresql` read-only into the container and use `postgres://bookorbit@/bookorbit?host=/run/postgresql`, avoiding `host.containers.internal`, TCP trust, bridge-specific HBA, and firewall changes.
- Define dynamic system user/group `bookorbit` on the host. Because Nix cannot interpolate dynamically allocated IDs at evaluation time, a oneshot service writes runtime `PUID`/`PGID` to `/run/bookorbit/environment` using `id`/`getent`; the generated OCI unit requires and follows that service.
- Use a 127.0.0.1 container port mapping and the repo’s Tailscale Caddy vhost helper by default. Avoid host networking so the app’s HTTP listener cannot bypass the intended local-only binding.
- Allocate `ports.bookorbit = 9032`, the next singleton service port after `remote-pi-relay`.
- State defaults to `/var/lib/bookorbit`; the configurable books mount defaults to `/var/lib/bookorbit/books`. Both are owned by the dynamic `bookorbit` account for the upstream image's privilege drop.
- PostgreSQL setup remains native and idempotent: ensure the database/role and create the three required extensions over `/run/postgresql`.
