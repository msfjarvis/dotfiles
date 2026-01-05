{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.umami;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.umami = {
    enable = mkEnableOption "umami analytics service";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = null;
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy localhost:${toString ports.umami}
        '';
      };
    };

    sops.secrets.umami-app-secret = {
      sopsFile = lib.snowfall.fs.get-file "secrets/umami.yaml";
    };

    services.umami = {
      enable = true;
      createPostgresqlDatabase = true;
      settings = {
        APP_SECRET_FILE = config.sops.secrets.umami-app-secret.path;
        PORT = ports.umami;
        HOSTNAME = "127.0.0.1";
        DISABLE_TELEMETRY = true;
      };
    };
  };
}
