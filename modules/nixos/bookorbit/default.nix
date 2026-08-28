{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.bookorbit;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
  portString = toString cfg.port;
  portMapping =
    if cfg.listenAddress == "0.0.0.0" then
      "${portString}:3000"
    else
      "${cfg.listenAddress}:${portString}:3000";
in
{
  options.services.${namespace}.bookorbit = {
    enable = mkEnableOption "BookOrbit";

    image = mkOption {
      type = types.str;
      default = "ghcr.io/bookorbit/bookorbit:latest";
      description = "BookOrbit OCI image to run.";
    };

    domain = mkOption {
      type = types.str;
      default = "bookorbit";
      description = "Tailscale hostname to expose through Caddy.";
    };

    appUrl = mkOption {
      type = types.str;
      default = "https://${cfg.domain}.${tailnetDomain}";
      description = "Public URL BookOrbit uses in links, device integrations, and OIDC callbacks.";
    };

    clientUrl = mkOption {
      type = types.str;
      default = cfg.appUrl;
      description = "Browser client URL when it differs from appUrl.";
    };

    listenAddress = mkOption {
      type = types.enum [
        "127.0.0.1"
        "0.0.0.0"
      ];
      default = "127.0.0.1";
      description = "Host address on which to publish BookOrbit's HTTP port.";
    };

    port = mkOption {
      type = types.port;
      default = ports.bookorbit;
      description = "Host TCP port mapped to BookOrbit's HTTP port.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/bookorbit";
      description = "Persistent host directory mounted at /data.";
    };

    booksDir = mkOption {
      type = types.str;
      default = "/var/lib/bookorbit/books";
      description = "Host directory containing books, mounted at /books.";
    };

    environmentFile = mkOption {
      type = types.path;
      example = "/run/secrets/bookorbit.env";
      description = ''
        Environment file containing JWT_SECRET and SETUP_BOOTSTRAP_TOKEN. It
        may also contain supported optional BookOrbit environment variables.
      '';
    };

    userId = mkOption {
      type = types.int;
      default = 1000;
      example = 1000;
      description = "PUID used by BookOrbit to access data and books.";
    };

    groupId = mkOption {
      type = types.int;
      default = 1000;
      example = 1000;
      description = "PGID used by BookOrbit to access data and books.";
    };

    podmanInterface = mkOption {
      type = types.str;
      default = "podman0";
      description = "Podman bridge interface used to reach native PostgreSQL.";
    };

    podmanNetworkCidr = mkOption {
      type = types.str;
      default = "10.88.0.0/16";
      description = "CIDR of the Podman bridge network used by BookOrbit.";
    };

    podmanHostAddress = mkOption {
      type = types.str;
      default = "10.88.0.1";
      description = "Host-side address of the Podman bridge network.";
    };

    libraryBrowseRoot = mkOption {
      type = types.str;
      default = "/books";
      description = "Directory at which BookOrbit's library picker starts.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open BookOrbit's HTTP port in the firewall.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 root root - -"
        "d ${cfg.booksDir} 0750 ${toString cfg.userId} ${toString cfg.groupId} - -"
      ];

      virtualisation = {
        podman.enable = true;
        oci-containers.backend = "podman";
      };

      # BookOrbit's PostgreSQL image includes pgvector. Add the equivalent
      # extension to the host's existing PostgreSQL package without changing
      # its major version or forcing a shared-instance upgrade.
      services.postgresql = {
        enable = true;
        extensions = ps: [ ps.pgvector ];
        ensureDatabases = [ "bookorbit" ];
        ensureUsers = [
          {
            name = "bookorbit";
            ensureDBOwnership = true;
          }
        ];
        # The app reaches this address through host.containers.internal; do
        # not expose the shared PostgreSQL server on every host interface.
        settings.listen_addresses = lib.mkForce "localhost,${cfg.podmanHostAddress}";
        authentication = lib.mkAfter ''
          host  bookorbit  bookorbit  ${cfg.podmanNetworkCidr}  trust
        '';
      };

      # The rootful Podman bridge reaches the host at host.containers.internal.
      networking.firewall.interfaces.${cfg.podmanInterface}.allowedTCPPorts = [ 5432 ];

      systemd.services.bookorbit-database-setup = {
        description = "Initialize the BookOrbit PostgreSQL extensions";
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
        before = [ "podman-bookorbit.service" ];
        requiredBy = [ "podman-bookorbit.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          Group = "postgres";
          RemainAfterExit = true;
        };
        script = ''
          set -eu
          psql=${config.services.postgresql.finalPackage}/bin/psql

          "$psql" \
            --host=/run/postgresql \
            --username=postgres \
            --dbname=bookorbit \
            --set=ON_ERROR_STOP=1 \
            --command='CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE EXTENSION IF NOT EXISTS vector;'
        '';
      };

      virtualisation.oci-containers.containers.bookorbit = {
        inherit (cfg) image;
        autoStart = true;
        environmentFiles = [ cfg.environmentFile ];
        ports = [ portMapping ];
        volumes = [
          "${cfg.dataDir}:/data"
          "${cfg.booksDir}:/books"
        ];
        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          POSTGRES_HOST = "host.containers.internal";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          APP_URL = cfg.appUrl;
          CLIENT_URL = cfg.clientUrl;
          TZ = config.time.timeZone;
          LIBRARY_BROWSE_ROOT = cfg.libraryBrowseRoot;
        }
        // {
          PUID = toString cfg.userId;
          PGID = toString cfg.groupId;
        };
        extraOptions = [
          "--pull=always"
          "--read-only"
          "--tmpfs=/tmp"
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_OVERRIDE"
          "--cap-add=FOWNER"
          "--cap-add=SETGID"
          "--cap-add=SETUID"
          "--security-opt=no-new-privileges"
          "--init"
        ];
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
        encode gzip zstd
        reverse_proxy 127.0.0.1:${portString}
      '';
    }
  ]);
}
