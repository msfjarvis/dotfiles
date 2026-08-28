# BookOrbit PostgreSQL startup network mismatch

## Evidence

The previous BookOrbit module configured the container to connect to PostgreSQL at Podman's `host.containers.internal` address (`10.88.0.1`) and added a TCP trust rule for the Podman CIDR. During PostgreSQL boot, the configured `10.88.0.1` address was unavailable; the running server actually had only `127.0.0.1`. Therefore the intended bridge path was not a reliable PostgreSQL endpoint at startup. The TCP bridge and its firewall exception were also unnecessary exposure for a same-host application.

## Root cause

The design coupled native PostgreSQL startup to Podman bridge addressing. `listen_addresses` and HBA configuration described a bridge endpoint that was not present when PostgreSQL started, while the only working local endpoint was the Unix socket under `/run/postgresql`.

## Corrected design

BookOrbit now uses the host PostgreSQL Unix socket, mounted read-only at `/run/postgresql` inside the container, with the complete node-postgres URI `postgres://bookorbit@/bookorbit?host=/run/postgresql`. The host database role and process Unix account are both named `bookorbit`, so default NixOS local peer authentication applies without a custom network HBA rule or database secret.

The container image expects numeric `PUID`/`PGID` values before dropping privileges. Nix cannot know the IDs assigned to a dynamic system account during evaluation, so `bookorbit-runtime-environment.service` resolves them at runtime with `id`, writes `/run/bookorbit/environment`, and is required by and ordered before `podman-bookorbit.service`. This preserves dynamic UID/GID allocation without baking collision-prone numbers into the module.

The HTTP Podman port mapping and its isolation remain unchanged. PostgreSQL no longer needs a bridge listener, TCP trust rule, or port 5432 firewall opening.
