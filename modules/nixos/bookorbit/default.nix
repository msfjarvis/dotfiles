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
  inherit (lib.${namespace}) ports;
  portString = toString cfg.port;
  publicUrl = "https://${cfg.domain}";
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
      description = "Fully-qualified public hostname for BookOrbit's HTTPS Caddy virtual host.";
      example = "books.example.com";
    };

    clientUrl = mkOption {
      type = types.str;
      default = publicUrl;
      description = "Browser client URL when it differs from BookOrbit's public URL.";
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
      example = 987;
      description = "Stable host UID used by BookOrbit and PostgreSQL peer authentication.";
    };

    groupId = mkOption {
      type = types.int;
      example = 984;
      description = "Stable host GID used by BookOrbit.";
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
        "d ${cfg.dataDir} 0750 bookorbit bookorbit - -"
        "d ${cfg.booksDir} 0750 bookorbit bookorbit - -"
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
      };

      users.groups.bookorbit.gid = cfg.groupId;
      users.users.bookorbit = {
        uid = cfg.userId;
        isSystemUser = true;
        group = "bookorbit";
      };

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
          "/run/postgresql:/run/postgresql:ro"
        ];
        environment = {
          PUID = toString cfg.userId;
          PGID = toString cfg.groupId;
          NODE_ENV = "production";
          PORT = "3000";
          DATABASE_URL = "postgres://bookorbit@/bookorbit?host=/run/postgresql";
          APP_URL = publicUrl;
          CLIENT_URL = cfg.clientUrl;
          TZ = config.time.timeZone;
          LIBRARY_BROWSE_ROOT = cfg.libraryBrowseRoot;
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

      services.caddy.virtualHosts."https://${cfg.domain}" = {
        logFormat = lib.${namespace}.mkReactionLogFormat cfg.domain;
        extraConfig = ''
          encode gzip zstd
          reverse_proxy 127.0.0.1:${portString}
        '';
      };
    }
  ]);
}
