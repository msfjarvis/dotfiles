# BookOrbit migration notes

## Result

`services.jarvis.bookorbit` replaces the upstream production `docker-compose.yml`:

- The BookOrbit application remains an OCI container using upstream's published `ghcr.io/bookorbit/bookorbit:latest` image. `nh search bookorbit` found no native Nixpkgs package.
- PostgreSQL is the host's native NixOS PostgreSQL instance with the packaged `pgvector` extension, rather than the upstream database container. The module does not force a major-version upgrade on a shared instance.
- The module creates the `bookorbit` database and role, then idempotently enables `uuid-ossp`, `pg_trgm`, and `vector`, which BookOrbit requires.
- App state and books default to `/var/lib/bookorbit` and `/var/lib/bookorbit/books`; both directories are owned by the dynamically allocated host `bookorbit` system user/group.
- The app is local-only by default and exposed through the repository's Tailscale Caddy helper at `https://bookorbit.tiger-shark.ts.net`.

## Required secret environment file

Set `environmentFile` to a mode-`0400` dotenv file containing the application secrets:

```dotenv
JWT_SECRET=<openssl rand -hex 32>
SETUP_BOOTSTRAP_TOKEN=<openssl rand -hex 16>
```

Database access is passwordless peer authentication over a Unix socket, not a database secret. The container mounts the host `/run/postgresql` socket directory read-only and uses:

```text
postgres://bookorbit@/bookorbit?host=/run/postgresql
```

The host and database role names match. The module defines a dynamic system `bookorbit` user/group, then generates `/run/bookorbit/environment` at service start with its runtime numeric `PUID`/`PGID`; this is passed to the upstream image so its entrypoint drops privileges before running migrations and the application, making peer authentication resolve to the host account. The generated file contains no secret.

The secret file can additionally include BookOrbit-supported optional variables such as `NODE_MAX_OLD_SPACE_SIZE`, `BOOK_DOCK_PATH`, `EMAIL_ENCRYPTION_KEY`, `MIGRATION_ENCRYPTION_KEY`, `MIGRATION_IMPORT_ROOT`, `LOG_LEVEL`, `OIDC_ALLOW_LOCAL_ISSUERS`, and `CSP_ALLOW_CLOUDFLARE_INSIGHTS`. Do not set the module-owned `DATABASE_URL`, `PUID`, `PGID`, `PORT`, `APP_URL`, `CLIENT_URL`, or `TZ` variables there.

With sops-nix, configure the secret outside this module and set `mode = "0400"` and `format = "dotenv"`.

## Networking assumption

The module enables Podman for the application HTTP container and preserves the isolated local HTTP port mapping. PostgreSQL is reached only through the read-only host socket mount; no Podman bridge address, TCP listener, HBA network rule, or database firewall exception is needed. The default NixOS local peer rule applies because the container process runs with the host `bookorbit` UID and the role is also named `bookorbit`.

The module adds `pgvector` to the configured native PostgreSQL package and intentionally does not silently change its major version. The database setup one-shot also uses `/run/postgresql` and runs after PostgreSQL is ready.

## Import/use

Snowfall loads `modules/nixos/bookorbit/default.nix` automatically. In a conventional NixOS configuration, import it explicitly:

```nix
{
  imports = [ ./modules/nixos/bookorbit ];

  services.jarvis.bookorbit = {
    enable = true;
    environmentFile = config.sops.secrets.bookorbit.path;
  };
}
```

For a public hostname rather than the default Tailscale vhost, set `appUrl` to the public HTTPS URL and add the matching Caddy virtual host outside this module. Do not also set `openFirewall` unless direct, non-proxied HTTP access is intentional.
