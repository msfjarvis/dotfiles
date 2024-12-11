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
    mkOption
    types
    ;
in
{
  options.services.${namespace}.firefly = {
    enable = mkEnableOption "firefly-iii and data importer";
    hostName = mkOption {
      type = types.str;
      description = "Tailscale hostname to expose firefly-iii under";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.hostName}.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/${cfg.hostName}
          root * ${config.services.firefly-iii.package}/public
          file_server
          php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket}
        '';
      };
      "https://${cfg.hostName}-import.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/${cfg.hostName}-import
          reverse_proxy 127.0.0.1:9091 {
            header_down X-Forwarded-Proto https
          }
        '';
      };
    };
    sops.secrets.firefly-iii = {
      sopsFile = lib.snowfall.fs.get-file "secrets/firefly-iii.yaml";
      owner = config.services.firefly-iii.user;
      inherit (config.services.firefly-iii) group;
    };
    services.firefly-iii = {
      enable = true;
      settings = {
        APP_ENV = "production";
        APP_URL = "https://${cfg.hostName}.tiger-shark.ts.net";
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
        ports = [ "127.0.0.1:9091:8080" ];
        extraOptions = [ "--log-opt=tag='firefly-importer'" ];
      };
    };
  };
}
