# BookOrbit migration notes

## Result

`services.jarvis.bookorbit` replaces the upstream production `docker-compose.yml`:

- The BookOrbit application remains an OCI container using upstream's published `ghcr.io/bookorbit/bookorbit:latest` image. `nh search bookorbit` found no native Nixpkgs package.
- PostgreSQL is the host's native NixOS PostgreSQL instance with the packaged `pgvector` extension, rather than the upstream `pgvector/pgvector:pg18` container. The module does not force a major-version upgrade on a shared instance.
- The module creates the `bookorbit` database and role, then idempotently enables `uuid-ossp`, `pg_trgm`, and `vector`, which BookOrbit requires.
- App state and books default to `/var/lib/bookorbit` and `/var/lib/bookorbit/books`; override `booksDir` for an existing library. The directories are writable by the container's configurable `userId`/`groupId`, which default to upstream's `1000:1000`.
- The app is local-only by default and exposed through the repository's Tailscale Caddy helper at `https://bookorbit.tiger-shark.ts.net`.

## Required secret environment file

Set `environmentFile` to a mode-`0400` dotenv file. It must contain:

```dotenv
JWT_SECRET=<openssl rand -hex 32>
SETUP_BOOTSTRAP_TOKEN=<openssl rand -hex 16>
```

The module grants the native `bookorbit` role passwordless access only from the configured Podman bridge. The file can additionally include BookOrbit-supported optional variables such as `NODE_MAX_OLD_SPACE_SIZE`, `BOOK_DOCK_PATH`, `EMAIL_ENCRYPTION_KEY`, `MIGRATION_ENCRYPTION_KEY`, `MIGRATION_IMPORT_ROOT`, `LOG_LEVEL`, `OIDC_ALLOW_LOCAL_ISSUERS`, and `CSP_ALLOW_CLOUDFLARE_INSIGHTS`. Do not set the module-owned `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_DB`, `PORT`, `APP_URL`, or `TZ` there.

With sops-nix, configure the secret outside this module and set `mode = "0400"` and `format = "dotenv"`.

## Networking assumption

The module enables Podman and configures it as the `virtualisation.oci-containers` backend. It uses Podman's default rootful bridge (`podman0`, `10.88.0.0/16`, host address `10.88.0.1`) to let the app reach native PostgreSQL via `host.containers.internal`. PostgreSQL listens only on localhost and that bridge address, accepts the dedicated role/database without a password only from that bridge CIDR, and the host firewall permits port 5432 only on the bridge interface.

If the host changes Podman's bridge interface or subnet, set `podmanInterface`, `podmanNetworkCidr`, and `podmanHostAddress` together. The module adds `pgvector` to the configured native PostgreSQL package and intentionally does not silently change its major version.

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
