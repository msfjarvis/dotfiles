{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.hatsu;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.hatsu = {
    enable = mkEnableOption "Hatsu ActivityPub bot";
    domain = mkOption {
      type = types.str;
      description = "Public domain to expose Hatsu under";
    };
    primaryAccount = mkOption {
      type = types.str;
      description = "Primary ActivityPub account for Hatsu";
      example = "user@example.com";
    };
    listenHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host that Hatsu listens on";
    };
    listenPort = mkOption {
      type = types.port;
      default = ports.hatsu;
      description = "Port that Hatsu listens on";
    };
    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = "Log level for Hatsu (e.g., debug, info, warn, error)";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "hatsu";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "hatsu" ];
    };

    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          encode gzip zstd
          reverse_proxy ${cfg.listenHost}:${toString cfg.listenPort}
        '';
      };
    };

    sops.secrets.hatsu-access-token = {
      sopsFile = lib.snowfall.fs.get-file "secrets/hatsu.yaml";
    };

    systemd.services.hatsu = {
      wantedBy = [ "default.target" ];
      requires = [
        "local-fs.target"
        "postgresql.service"
      ];
      after = [
        "nss-user-lookup.target"
        "local-fs.target"
        "network.target"
        "postgresql.service"
      ];
      wants = [
        "local-fs.target"
        "network.target"
      ];

      serviceConfig = {
        User = "hatsu";
        Group = "hatsu";
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "simple";
        StateDirectory = "hatsu";
        StateDirectoryMode = "0700";
        EnvironmentFile = config.sops.secrets.hatsu-access-token.path;
      };

      environment = {
        HATSU_DOMAIN = cfg.domain;
        HATSU_LISTEN_HOST = cfg.listenHost;
        HATSU_LISTEN_PORT = toString cfg.listenPort;
        HATSU_PRIMARY_ACCOUNT = cfg.primaryAccount;
        HATSU_DATABASE_URL = "postgres://hatsu/hatsu?host=/run/postgresql";
        HATSU_LOG = cfg.logLevel;
      };

      script = ''
        ${lib.getExe pkgs.hatsu}
      '';
    };

    users.users = {
      hatsu = {
        group = "hatsu";
        createHome = false;
        description = "Hatsu ActivityPub bot user";
        isSystemUser = true;
      };
    };

    users.groups = {
      hatsu = { };
    };
  };
}
