{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.prometheus;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.prometheus = {
    enable = mkEnableOption "Prometheus";
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${config.services.grafana.settings.server.domain}" = {
        extraConfig = ''
          bind tailscale/grafana
          tailscale_auth
          reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port} {
            header_up X-Webauth-User {http.auth.user.tailscale_user}
          }
        '';
      };

      "https://prometheus.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/prometheus
          tailscale_auth
          reverse_proxy :${toString config.services.prometheus.port} {
            header_up X-Webauth-User {http.auth.user.tailscale_user}
          }
        '';
      };
    };
    services.grafana = {
      enable = true;
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
          job_name = "wailord";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ]; }
          ];
        }
        {
          job_name = "caddy";
          static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
        }
        {
          job_name = "miniflux";
          static_configs = [ { targets = [ config.services.miniflux.config.LISTEN_ADDR ]; } ];
        }
      ];
    };
  };
}
