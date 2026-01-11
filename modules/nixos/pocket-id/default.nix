{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.pocket-id;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.${namespace}.pocket-id = {
    enable = mkEnableOption "Enable the pocket-id OIDC provider";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = "auth.msfjarvis.dev";
    };
    settings = mkOption {
      type = types.attrs;
      description = "Extra settings";
      default = { };
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy ${config.services.pocket-id.settings.HOST}:${config.services.pocket-id.settings.PORT}
        '';
      };
    };
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "pocket-id";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "pocket-id" ];
    };
    sops.secrets.pocket-id = {
      sopsFile = lib.snowfall.fs.get-file "secrets/pocket-id.env";
      owner = config.services.pocket-id.user;
      inherit (config.services.pocket-id) group;
      format = "dotenv";
    };
    services.pocket-id = {
      enable = true;
      environmentFile = config.sops.secrets.pocket-id.path;
      settings = {
        APP_URL = "https://${cfg.domain}";
        DB_CONNECTION_STRING = "postgres://pocket-id/pocket-id?host=/run/postgresql";
        HOST = "127.0.0.1";
        LOG_JSON = true;
        METRICS_ENABLED = true;
        OTEL_EXPORTER_PROMETHEUS_HOST = "127.0.0.1";
        OTEL_EXPORTER_PROMETHEUS_PORT = toString lib.${namespace}.ports.exporters.pocket-id;
        OTEL_METRICS_EXPORTER = "prometheus";
        PORT = toString lib.${namespace}.ports.pocket-id;
        TRUST_PROXY = true;
        UI_CONFIG_DISABLED = true;
      }
      // cfg.settings;
    };
    services.prometheus.scrapeConfigs = [
      {
        job_name = "pocket-id";
        static_configs = with config.services.pocket-id.settings; [
          {
            targets = [ "${OTEL_EXPORTER_PROMETHEUS_HOST}:${toString OTEL_EXPORTER_PROMETHEUS_PORT}" ];
          }
        ];
      }
    ];
  };
}
