{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.gitea;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.${namespace}.gitea = {
    enable = mkEnableOption "Gitea Git hosting server";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy :${toString config.services.gitea.settings.server.HTTP_PORT}
        '';
      };
    };
    services.gitea = {
      enable = true;
      appName = "Harsh Shandilya's Git hosting";
      settings = {
        mailer = {
          ENABLED = false;
        };
        oauth2 = {
          # Increase token expiry to one day as a workaround for GCM
          # handling token refresh poorly. Refs:
          # - https://forum.gitea.com/t/authentication-failed-for-but-running-the-command-again-works/8521
          # - https://github.com/git-ecosystem/git-credential-manager/issues/1408
          # - https://github.com/go-gitea/gitea/issues/31470
          ACCESS_TOKEN_EXPIRATION_TIME = 86400;
        };
        other = {
          SHOW_FOOTER_POWERED_BY = false;
        };
        repository = {
          DISABLE_STARS = false;
        };
        server = {
          DISABLE_SSH = true;
          DOMAIN = "${cfg.domain}";
          ENABLE_GZIP = true;
          LANDING_PAGE = "explore";
          ROOT_URL = "https://${cfg.domain}/";
        };
        service = {
          COOKIE_SECURE = true;
          DISABLE_REGISTRATION = true;
        };
        ui = {
          DEFAULT_THEME = "catppuccin-mocha-mauve";
        };
      };
    };

  };
}
