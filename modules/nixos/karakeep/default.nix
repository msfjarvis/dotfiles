{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.karakeep;
  inherit (lib.${namespace}) ports tailnetDomain;
in
{
  options.services.${namespace}.karakeep = {
    enable = lib.mkEnableOption "Karakeep bookmark manager";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Public hostname for Karakeep.";
      example = "later.example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      browser.enable = false;
      extraEnvironment = {
        BROWSER_WEB_URL = "http://chrome-cdp.${tailnetDomain}:9222";
        HOSTNAME = "127.0.0.1";
        PORT = toString ports.karakeep;
        NEXTAUTH_URL = "https://${cfg.domain}";
        DISABLE_SIGNUPS = "true";
      };
    };

    services.caddy.virtualHosts."https://${cfg.domain}" = {
      logFormat = lib.${namespace}.mkReactionLogFormat cfg.domain;
      extraConfig = ''
        encode gzip zstd
        reverse_proxy 127.0.0.1:${toString ports.karakeep}
      '';
    };
  };
}
