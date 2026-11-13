# plMail deployment

The upstream all-in-one image runs the web server, workers, scheduler and Mercure in one container. PostgreSQL runs natively. The container runs as the host `plmail` user and connects directly to the mounted PostgreSQL Unix socket with peer authentication; no database TCP listener or proxy is required. The OCI backend must not remap the container UID to a different host UID. PostgreSQL must listen on its usual `/run/postgresql` socket and permit peer authentication for `plmail`.

The HTTP port is loopback-only and Caddy exposes it over Tailscale. Port 9034 is the next free singleton service port in `lib/ports.nix`. This private endpoint cannot receive external provider webhooks; upstream falls back to polling. Create the first administrator promptly after enabling the service.

The image generates application secrets under `/var/lib/pl-mail/secrets`. Back up the entire data directory and PostgreSQL separately; losing the encryption key makes saved mailbox credentials unreadable. If migrating data created by the previous root-run container, stop the container and change ownership recursively to `plmail:plmail` before starting it as the unprivileged user. NixOS allocates the system user and group IDs; the container service looks them up on startup. The default image is pinned to upstream release `0.4.3`. Upgrades may apply database migrations automatically. Upstream targets PostgreSQL 18; verify the host PostgreSQL version and extension requirements before deployment.

This module defines a service but does not enable it on a host. For a host using this repository's automatically discovered modules:

```nix
{
  services.jarvis.pl-mail.enable = true;
}
```

For an external configuration, import `./modules/nixos/pl-mail/default.nix` and supply this repository's `namespace` and `lib.jarvis` module arguments.
