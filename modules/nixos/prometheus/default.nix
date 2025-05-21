{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.prometheus;
  email.text = ''
    {{ template "__alertmanagerURL" . }}

    {{ range .Alerts }}
      {{ .Labels.severity }}: {{ .Annotations.summary }}
        {{ .Annotations.description }}
      *Details:*
        {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
        {{ end }}
    {{ end }}
  '';
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
    grafana = {
      enable = mkEnableOption "Grafana";
    };
    host = mkOption {
      type = types.str;
      default = "prom-${config.networking.hostName}";
      description = "Host name for the Prometheus server";
    };
    port = mkOption {
      type = types.int;
      # TODO: start segragating these into 9_${toInt service}_xy
      default = 9009;
      description = "Port for the alertmanager server";
    };
    alertmanager = {
      enable = mkEnableOption "Alertmanager";
      port = mkOption {
        type = types.int;
        # TODO: start segragating these into 9_${toInt service}_xy
        default = 9010;
        description = "Port for the alertmanager server";
      };
      host = mkOption {
        type = types.str;
        default = "alerts-${config.networking.hostName}";
        description = "Host name for the alertmanager server";
      };
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = mkMerge [
      (mkIf cfg.grafana.enable {
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
        "https://${cfg.alertmanager.host}.tiger-shark.ts.net" = {
          extraConfig = ''
            bind tailscale/${cfg.alertmanager.host}
            reverse_proxy 127.0.0.1:${toString config.services.prometheus.alertmanager.port}
          '';
        };
      }
    ];
    services.grafana = {
      inherit (cfg.grafana) enable;
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
    sops.secrets.prometheus-alertmanager = {
      sopsFile = lib.snowfall.fs.get-file "secrets/alertmanager.env";
      format = "dotenv";
    };
    services.prometheus = {
      enable = true;
      inherit (cfg) port;
      extraFlags = [ "--web.enable-admin-api" ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          # TODO: start segragating these into 9_${toInt service}_xy
          port = 9002;
        };
        systemd = {
          enable = true;
          # TODO: start segragating these into 9_${toInt service}_xy
          port = 9003;
        };
      };
      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ]; }
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
              ];
              labels = {
                alias = "alertmanager";
              };
            }
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.port}"
              ];
              labels = {
                alias = "prometheus";
              };
            }
          ];
        }
        {
          job_name = "caddy";
          static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
        }
      ];

      alertmanagers = [
        {
          scheme = "http";
          path_prefix = "/";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.alertmanager.port}" ]; }
          ];
        }
      ];

      alertmanager = {
        enable = true;
        inherit (cfg.alertmanager) port;
        webExternalUrl = "https://${cfg.alertmanager.host}.tiger-shark.ts.net/";
        environmentFile = config.sops.secrets.prometheus-alertmanager.path;
        extraFlags = [
          "--cluster.listen-address="
        ];
        configuration = {
          route = {
            receiver = "email";
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "4h";
            group_by = [
              "alertname"
              "job"
            ];
            routes = [ ];
          };
          receivers = [
            {
              name = "email";
              email_configs = [
                {
                  auth_password = "$ALERTMANAGER_EMAIL_PASSWORD";
                  to = "me@msfjarvis.dev";
                  from = "monitoring@msfjarvis";
                  smarthost = "smtp.purelymail.com:587";
                  auth_username = "me@msfjarvis.dev";
                  auth_identity = "me@msfjarvis.dev";
                  send_resolved = true;
                  inherit (email) text;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
