{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.prometheus;
  inherit (lib)
    mkEnableOption
    mkMerge
    mkOption
    mkIf
    types
    ;
in
{
  options.services.${namespace}.prometheus = {
    enable = mkEnableOption "Prometheus";
    enableGrafana = mkEnableOption "Grafana";
    host = mkOption {
      type = types.str;
      default = "prom-${config.networking.hostName}";
      description = "Host name for the Prometheus server";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = mkMerge [
      (mkIf cfg.enableGrafana {
        "https://${config.services.grafana.settings.server.domain}" = {
          extraConfig = ''
            bind tailscale/grafana
            tailscale_auth
            reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port} {
              header_up X-Webauth-User {http.auth.user.tailscale_user}
            }
          '';
        };
      })
      {
        "https://${cfg.host}.tiger-shark.ts.net" = {
          extraConfig = ''
            bind tailscale/${cfg.host}
            reverse_proxy 127.0.0.1:${toString config.services.prometheus.port}
          '';
        };
      }
    ];
    services.grafana = {
      enable = cfg.enableGrafana;
      settings = {
        "auth.proxy" = {
          enabled = true;
          auto_sign_up = false;
          enable_login_token = false;
        };
        server = {
          domain = "grafana.tiger-shark.ts.net";
          http_addr = "127.0.0.1";
          http_port = 2342;
        };
      };
    };
    services.prometheus = {
      enable = true;
      port = 9001;
      extraFlags = [ "--web.enable-admin-api" ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
        systemd = {
          enable = true;
          port = 9003;
        };
      };
      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ]; }
          ];
        }
        {
          job_name = "caddy";
          static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
        }
      ];
    };
  };
}
