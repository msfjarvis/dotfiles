{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.miniflux;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports mkSystemSecret;
in
{
  options.services.${namespace}.miniflux = {
    enable = mkEnableOption "Miniflux RSS reader";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = "read.msfjarvis.dev";
    };
    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional configuration options for Miniflux";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy ${config.services.miniflux.config.LISTEN_ADDR}
        '';
      };
    };

    users = {
      groups.miniflux = { };
      users = {
        miniflux = {
          isSystemUser = true;
          group = config.users.groups.miniflux.name;
        };
      };
    };

    sops.secrets.feed-auth = mkSystemSecret {
      owner = config.users.users.miniflux.name;
      file = "feed-auth";
      format = "dotenv";
      restartUnits = [ "miniflux.service" ];
    };

    services.miniflux = {
      enable = true;
      createDatabaseLocally = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString ports.miniflux}";
        FETCH_ODYSEE_WATCH_TIME = 1;
        FETCH_YOUTUBE_WATCH_TIME = 1;
        LOG_DATE_TIME = 1;
        LOG_FORMAT = "json";
        WORKER_POOL_SIZE = 2;
        BASE_URL = "https://${cfg.domain}/";
        HTTPS = 1;
        METRICS_COLLECTOR = 1;
        WEBAUTHN = 1;
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_REDIRECT_URL = "https://${cfg.domain}/oauth2/oidc/callback";
        OAUTH2_USER_CREATION = 1;
        DISABLE_LOCAL_AUTH = 1;
      }
      // cfg.extraConfig;
      adminCredentialsFile = config.sops.secrets.feed-auth.path;
    };

    services.prometheus.scrapeConfigs =
      mkIf (config.services.miniflux.config.METRICS_COLLECTOR or 0 == 1)
        [
          {
            job_name = "miniflux";
            static_configs = [ { targets = [ config.services.miniflux.config.LISTEN_ADDR ]; } ];
          }
        ];
  };
}
