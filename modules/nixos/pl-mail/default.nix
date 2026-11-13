{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.pl-mail;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
  backend = config.virtualisation.oci-containers.backend;
  # NixOS allocates system IDs at activation, after the OCI command is built.
  # Insert the allocated IDs when the container is started instead.
  containerRuntime = pkgs.writeShellScriptBin backend ''
    set -eu
    if [ "''${1:-}" = run ]; then
      shift
      uid=$(${pkgs.coreutils}/bin/id -u plmail)
      gid=$(${pkgs.coreutils}/bin/id -g plmail)
      exec ${pkgs.${backend}}/bin/${backend} run --user "$uid:$gid" "$@"
    fi
    exec ${pkgs.${backend}}/bin/${backend} "$@"
  '';
in
{
  options.services.${namespace}.pl-mail = {
    enable = mkEnableOption "plMail webmail";
    domain = mkOption {
      type = types.str;
      default = "pl-mail";
      description = "Tailscale hostname for plMail.";
    };
    port = mkOption {
      type = types.port;
      default = ports.pl-mail;
      description = "Loopback port for the plMail web interface.";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/pl-mail";
      description = "Persistent plMail data and generated secrets.";
    };
    image = mkOption {
      type = types.str;
      default = "ghcr.io/karatektus/pl_mail:0.4.3";
      description = "Upstream plMail image.";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "plmail" ];
      extensions = extensions: [ extensions.pgvector ];
      ensureUsers = [
        {
          name = "plmail";
          ensureDBOwnership = true;
        }
      ];
    };
    users.users.plmail = {
      isSystemUser = true;
      group = "plmail";
    };
    users.groups.plmail = { };

    # plMail detects available pgvector files and tries to create the extension,
    # which requires a superuser. Install it before the unprivileged app starts.
    systemd.services.pl-mail-postgresql = {
      description = "Install plMail PostgreSQL extension";
      requires = [ "postgresql-setup.service" ];
      after = [ "postgresql-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        RemainAfterExit = true;
      };
      path = [ config.services.postgresql.finalPackage ];
      environment.PGPORT = toString config.services.postgresql.settings.port;
      script = ''
        psql -X -v ON_ERROR_STOP=1 -d plmail -c 'CREATE EXTENSION IF NOT EXISTS vector'
      '';
    };

    systemd.services."${backend}-pl-mail" = {
      requires = [ "pl-mail-postgresql.service" ];
      after = [ "pl-mail-postgresql.service" ];
      path = lib.mkBefore [ containerRuntime ];
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0700 plmail plmail - -" ];
    virtualisation.oci-containers.containers.pl-mail = {
      inherit (cfg) image;
      autoStart = true;
      ports = [ "127.0.0.1:${toString cfg.port}:8080" ];
      volumes = [
        "${cfg.dataDir}:/app/var/data"
        "/run/postgresql:/run/postgresql:ro"
      ];
      environment = {
        APP_ENV = "prod";
        APP_ALL_IN_ONE = "1";
        APP_STORAGE_DIR = "/app/var/data";
        APP_SECRETS_DIR = "/app/var/data/secrets";
        APP_SECRETS_FILE = "/app/var/data/secrets/generated.env";
        APP_PUBLIC_URL = "https://${cfg.domain}.${tailnetDomain}";
        SERVER_NAME = ":8080";
        # The placeholder prevents the entrypoint replacing this URL. PostgreSQL
        # authenticates the container's host UID via peer credentials instead.
        DATABASE_URL = "postgresql://plmail:unused@localhost:${toString config.services.postgresql.settings.port}/plmail?host=%2Frun%2Fpostgresql&charset=utf8";
      };
      extraOptions = [
        "--init"
        "--stop-timeout=35"
        "--health-cmd=curl -f http://localhost:8080/healthz || exit 1"
      ];
    };
    services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
      import blackholeCrawlers
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
