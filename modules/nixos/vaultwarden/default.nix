{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.vaultwarden;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
    backvault = {
      enable = mkEnableOption "BackVault backups for Vaultwarden";
      dataPath = mkOption {
        type = types.str;
        default = "/var/lib/backvault";
        description = "Path to store BackVault's encrypted credentials and backups";
      };
      intervalHours = mkOption {
        type = types.ints.positive;
        default = 12;
        description = "Hours between BackVault backups";
      };
      retainDays = mkOption {
        type = types.ints.unsigned;
        default = 7;
        description = "Days of BackVault backups to retain; zero disables cleanup";
      };
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        logFormat = lib.${namespace}.mkReactionLogFormat cfg.domain;
        extraConfig = ''
          reverse_proxy 127.0.0.1:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up X-Real-IP {remote_host}
          }
        '';
      };
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };

    sops.secrets.vaultwarden = {
      sopsFile = lib.snowfall.fs.get-file "secrets/vaultwarden.env";
      owner = "vaultwarden";
      group = "vaultwarden";
      format = "dotenv";
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets.vaultwarden.path;
      config = {
        DATABASE_URL = "postgres://vaultwarden?host=/run/postgresql";
        DOMAIN = "https://${cfg.domain}";
        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-overlay,autofill-v2,browser-fileless-import,extension-refresh,fido2-vault-credentials,inline-menu-positioning-improvements,ssh-key-vault-item,ssh-agent";
        INVITATIONS_ALLOWED = false;
        PUSH_ENABLED = true;
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
        PUSH_RELAY_URI = "https://api.bitwarden.eu";
        ROCKET_PORT = ports.vaultwarden;
        SIGNUPS_ALLOWED = false;
        USE_SYSLOG = true;
      };
    };

    # Backvault configuration
    virtualisation = mkIf cfg.backvault.enable {
      podman.enable = true;
      oci-containers = {
        backend = "podman";
        containers.backvault = {
          image = "ghcr.io/mvfc/backvault:2.0.15";
          environment = {
            BW_SERVER = "https://${cfg.domain}";
            BACKUP_ENCRYPTION_MODE = "bitwarden";
            BACKUP_INTERVAL_HOURS = toString cfg.backvault.intervalHours;
            RETAIN_DAYS = toString cfg.backvault.retainDays;
            TZ = config.time.timeZone;
            PUID = "1000";
            PGID = "1000";
          };
          volumes = [
            "${cfg.backvault.dataPath}/backups:/app/backups:rw"
            "${cfg.backvault.dataPath}/db:/app/db:rw"
          ];
          ports = [
            "127.0.0.1:8080:8080/tcp"
          ];
          log-driver = "journald";
          autoStart = true;
          extraOptions = [ "--umask=0077" ];
        };
      };
    };

    systemd.services.podman-backvault = mkIf cfg.backvault.enable {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      unitConfig.RequiresMountsFor = [
        "${cfg.backvault.dataPath}/backups"
        "${cfg.backvault.dataPath}/db"
      ];
    };

    # Ensure data directories exist
    systemd.tmpfiles.rules = mkIf cfg.backvault.enable [
      "d ${cfg.backvault.dataPath} 0711 root root -"
      "d ${cfg.backvault.dataPath}/backups 0700 1000 1000 -"
      "d ${cfg.backvault.dataPath}/db 0700 1000 1000 -"
      "z ${cfg.backvault.dataPath}/backups/*.enc 0600 1000 1000 -"
      "z ${cfg.backvault.dataPath}/db/backvault.db* 0600 1000 1000 -"
    ];
  };
}
