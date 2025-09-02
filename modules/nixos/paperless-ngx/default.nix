{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.paperless-ngx;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.paperless-ngx = {
    enable = mkEnableOption "paperless-ngx, a document management service";
    domain = mkOption {
      type = types.str;
      description = "Domain to expose paperless-ngx on";
    };
  };
  config = mkIf cfg.enable {

    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = with config.services.paperless; {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy ${address}:${toString port}
        '';
      };
    };

    sops.secrets.paperless-ngx = {
      sopsFile = lib.snowfall.fs.get-file "secrets/paperless.env";
      format = "dotenv";
      owner = config.services.paperless.user;
    };
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = ports.paperless-ngx;
      configureTika = false;
      database.createLocally = true;
      domain = cfg.domain;
      environmentFile = config.sops.secrets.paperless-ngx.path;
      settings = {
        # Authentication
        PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = true;
        PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
        PAPERLESS_DISABLE_REGULAR_LOGIN = true;
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;

        # Disable automatic imports
        PAPERLESS_CONSUMER_DISABLE = true;

        # Only allow HTTPS webhooks
        PAPERLESS_WEBHOOKS_ALLOWED_SCHEMES = "https";
      };
    };
  };
}
