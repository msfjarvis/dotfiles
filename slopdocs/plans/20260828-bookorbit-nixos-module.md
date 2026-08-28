# BookOrbit NixOS module

Decision: add `services.jarvis.bookorbit` as an OCI-backed BookOrbit application paired with native PostgreSQL plus pgvector. The upstream publishes `ghcr.io/bookorbit/bookorbit:latest`; `nh search bookorbit` returned no Nixpkgs package. PostgreSQL is translated natively because the required pgvector extension is packaged by NixOS PostgreSQL.

- Effective upstream deployment input: root `docker-compose.yml` and `.env.example`; there are no production overlays. The app mounts `/books` and `/data`, exposes port 3000, and depends on PostgreSQL 18 with `uuid-ossp`, `pg_trgm`, and `vector`.
- Preserve the container for the app. It receives an administrator-supplied secret environment file containing `POSTGRES_PASSWORD`, `JWT_SECRET`, and `SETUP_BOOTSTRAP_TOKEN`. A one-shot native PostgreSQL setup service uses that password to configure the app role and creates the three required extensions idempotently.
- Use a 127.0.0.1 container port mapping and the repo’s Tailscale Caddy vhost helper by default. Avoid host networking so the app’s HTTP listener cannot bypass the intended local-only binding.
- Allocate `ports.bookorbit = 9032`, the next singleton service port after `remote-pi-relay`.
- State defaults to `/var/lib/bookorbit`; the configurable books mount defaults to `/var/lib/bookorbit/books`. The upstream `PUID`/`PGID` defaults of `1000:1000` are configurable so an externally owned library remains readable by the container process.
- The module enables the Podman OCI backend and scopes native PostgreSQL's additional listener, pg_hba rule, and firewall opening to configurable Podman bridge values. It adds pgvector through the NixOS extension mechanism without changing an existing shared PostgreSQL instance's major version.
