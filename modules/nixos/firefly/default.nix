{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.firefly;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
in
{
  options.services.${namespace}.firefly = {
    enable = mkEnableOption "firefly-iii and data importer";
    domain = mkOption {
      type = types.str;
      description = "Tailscale domain to expose firefly-iii under";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = mkMerge [
      (mkTailscaleVHost cfg.domain ''
        root * ${config.services.firefly-iii.package}/public
        file_server
        php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket}
      '')
      (mkTailscaleVHost "${cfg.domain}-import" ''
        reverse_proxy 127.0.0.1:${toString ports.firefly-importer} {
          header_down X-Forwarded-Proto https
        }
      '')
    ];
    sops.secrets.firefly-iii = {
      sopsFile = lib.snowfall.fs.get-file "secrets/firefly-iii.yaml";
      owner = config.services.firefly-iii.user;
      inherit (config.services.firefly-iii) group;
    };
    services.firefly-iii = {
      enable = true;
      settings = {
        APP_ENV = "production";
        APP_URL = "https://${cfg.domain}.${tailnetDomain}";
        APP_KEY_FILE = config.sops.secrets.firefly-iii.path;
        DB_CONNECTION = "sqlite";
        LOG_CHANNEL = "syslog";
        TRUSTED_PROXIES = "*";
        TZ = config.time.timeZone;
      };
      inherit (config.services.caddy) user;
      inherit (config.services.caddy) group;
    };
    virtualisation.oci-containers.containers = {
      "firefly-importer" = {
        image = "fireflyiii/data-importer:version-1.5.3";
        autoStart = true;
        environment = {
          TRUSTED_PROXIES = "*";
          FIREFLY_III_URL = config.services.firefly-iii.settings.APP_URL;
          inherit (config.services.firefly-iii.settings) TZ;
        };
        ports = [ "127.0.0.1:${toString ports.firefly-importer}:8080" ];
        extraOptions = [ "--log-opt=tag='firefly-importer'" ];
      };
    };
  };
}
