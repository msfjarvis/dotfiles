{
  config,
  lib,
  namespace,
  pkgs,
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
  runtimeEnvironmentFile = "/run/bookorbit/environment";
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

      users.groups.bookorbit = { };
      users.users.bookorbit = {
        isSystemUser = true;
        group = "bookorbit";
      };

      systemd.services.bookorbit-runtime-environment = {
        description = "Generate BookOrbit container user environment";
        serviceConfig = {
          Type = "oneshot";
          RuntimeDirectory = "bookorbit";
          RuntimeDirectoryMode = "0755";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail
          uid=$(${pkgs.coreutils}/bin/id -u bookorbit)
          gid=$(${pkgs.coreutils}/bin/id -g bookorbit)
          tmp=${runtimeEnvironmentFile}.tmp
          {
            printf 'PUID=%s\n' "$uid"
            printf 'PGID=%s\n' "$gid"
          } > "$tmp"
          ${pkgs.coreutils}/bin/chmod 0644 "$tmp"
          ${pkgs.coreutils}/bin/mv -f "$tmp" ${runtimeEnvironmentFile}
        '';
      };

      systemd.services.podman-bookorbit = {
        after = [
          "bookorbit-runtime-environment.service"
          "postgresql.service"
        ];
        requires = [
          "bookorbit-runtime-environment.service"
          "postgresql.service"
        ];
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
        environmentFiles = [
          cfg.environmentFile
          runtimeEnvironmentFile
        ];
        ports = [ portMapping ];
        volumes = [
          "${cfg.dataDir}:/data"
          "${cfg.booksDir}:/books"
          "/run/postgresql:/run/postgresql:ro"
        ];
        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          DATABASE_URL = "postgres://bookorbit@/bookorbit?host=/run/postgresql";
          APP_URL = cfg.appUrl;
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

      services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
        encode gzip zstd
        reverse_proxy 127.0.0.1:${portString}
      '';
    }
  ]);
}
