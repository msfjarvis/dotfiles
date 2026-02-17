{
  config,
  lib,
  namespace,
  ...
}:
let
  readFromFile = path: "$__file{${path}}";
  cfg = config.services.${namespace}.prometheus;
  email.text = ''
    {{ template "__alertmanagerURL" . }}

    {{ range .Alerts }}
      Severity: {{ or .Labels.severity "info" }}
      Summary: {{ or .Annotations.summary "Alert fired" }}
      {{- if .Labels.target }}
      Target: {{ .Labels.target }}
      {{- end }}
      Description: {{ .Annotations.description }}
      Source: {{ .GeneratorURL }}
      Labels:
      {{ range .Labels.SortedPairs }} - {{ .Name }}: {{ .Value }}
      {{ end }}
      Annotations:
      {{- range .Annotations.SortedPairs }}
        {{- if and (ne .Name "summary") (ne .Name "description") }} - {{ .Name }}: {{ .Value }}
        {{- end }}
      {{- end }}
      {{- if eq .Labels.job "http_probe" }}
      Blackbox diagnostics:
       - probe_success{job="{{ .Labels.job }}",target="{{ .Labels.target }}"}
       - probe_http_status_code{job="{{ .Labels.job }}",target="{{ .Labels.target }}"}
       - probe_ssl_earliest_cert_expiry{job="{{ .Labels.job }}",target="{{ .Labels.target }}"} - time()
       - probe_duration_seconds{job="{{ .Labels.job }}",target="{{ .Labels.target }}"}
      {{- end }}

    {{ end }}
  '';
  telegram.text = ''{{ if .CommonAnnotations.summary }}{{ .CommonAnnotations.summary }}{{ else }}Alert: {{ or .CommonLabels.alertname "UnknownAlert" }} on {{ if .CommonLabels.target }}{{ .CommonLabels.target }}{{ else }}unknown{{ end }}{{ end }}'';

  inherit (lib)
    mkEnableOption
    mkMerge
    mkOption
    mkIf
    types
    ;
  inherit (lib.${namespace}) ports mkTailscaleVHost tailnetDomain;
in
{
  options.services.${namespace}.prometheus = {
    enable = mkEnableOption "Prometheus";
    grafana = {
      enable = mkEnableOption "Grafana";
      host = mkOption {
        type = types.str;
        description = "Host name for the Prometheus server";
      };
    };
    host = mkOption {
      type = types.str;
      default = "prom-${config.networking.hostName}";
      description = "Host name for the Prometheus server";
    };
    port = mkOption {
      type = types.int;
      default = ports.prometheus;
      description = "Port for the alertmanager server";
    };
    alertmanager = {
      enable = mkOption {
        default = config.services.${namespace}.prometheus.enable;
        example = true;
        description = "Whether to enable Alertmanager.";
        type = lib.types.bool;
      };
      port = mkOption {
        type = types.int;
        default = ports.alertmanager;
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
            reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}
          '';
        };
      })
      (mkTailscaleVHost cfg.host ''
        reverse_proxy 127.0.0.1:${toString config.services.prometheus.port}
      '')
      (mkTailscaleVHost cfg.alertmanager.host ''
        reverse_proxy 127.0.0.1:${toString config.services.prometheus.alertmanager.port}
      '')
    ];
    sops.secrets = mkMerge [
      {
        prometheus-alertmanager = {
          sopsFile = lib.snowfall.fs.get-file "secrets/alertmanager.env";
          format = "dotenv";
        };
      }
      (mkIf cfg.grafana.enable {
        grafana_oauth_client_id = {
          sopsFile = lib.snowfall.fs.get-file "secrets/grafana.yaml";
          owner = "grafana";
          restartUnits = [ "grafana.service" ];
        };
      })
      (mkIf cfg.grafana.enable {
        grafana_oauth_client_secret = {
          sopsFile = lib.snowfall.fs.get-file "secrets/grafana.yaml";
          owner = "grafana";
          restartUnits = [ "grafana.service" ];
        };
      })
    ];
    services.grafana = mkIf cfg.grafana.enable {
      inherit (cfg.grafana) enable;
      settings = {
        "auth.generic_oauth" = {
          enabled = true;
          name = "Pocket ID";
          client_id = readFromFile config.sops.secrets.grafana_oauth_client_id.path;
          client_secret = readFromFile config.sops.secrets.grafana_oauth_client_secret.path;
          auth_url = "https://auth.msfjarvis.dev/authorize";
          token_url = "https://auth.msfjarvis.dev/api/oidc/token";
          api_url = "";
          auth_style = "AutoDetect";
          scopes = "openid,email,profile";
          allow_sign_up = true;
          auto_login = false;
          email_attribute_name = "email:primary";
          skip_org_role_sync = true;
          signout_redirect_url = "";
        };
        server = {
          domain = cfg.grafana.host;
          root_url = "https://${cfg.grafana.host}";
          http_addr = "127.0.0.1";
          http_port = ports.grafana;
        };
        # Old hardcoded value that was removed, I don't use anything that relies on it being secret.
        security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };
    };
    services.prometheus = {
      enable = true;
      inherit (cfg) port;
      extraFlags = [ "--web.enable-admin-api" ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = ports.exporters.node;
        };
        systemd = {
          enable = true;
          port = ports.exporters.systemd;
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
          static_configs = [ { targets = [ "127.0.0.1:${toString ports.caddy}" ]; } ];
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
        inherit (cfg.alertmanager) enable port;
        webExternalUrl = "https://${cfg.alertmanager.host}.${tailnetDomain}/";
        environmentFile = config.sops.secrets.prometheus-alertmanager.path;
        configuration = {
          route = {
            receiver = "telegram";
            group_interval = "5m";
            repeat_interval = "10m";
            group_by = [
              "alertname"
              "job"
            ];
            routes = [
              {
                receiver = "telegram";
                continue = true;
              }
              { receiver = "email"; }
            ];
            # receiver = "email";
            # group_wait = "30s";
            # group_interval = "5m";
            # repeat_interval = "4h";
            # group_by = [
            #   "alertname"
            #   "job"
            # ];
            # routes = [ ];
          };
          receivers = [
            {
              name = "email";
              email_configs = [
                {
                  auth_password = "$ALERTMANAGER_EMAIL_PASSWORD";
                  to = "me@msfjarvis.dev";
                  from = "monitoring@msfjarvis.dev";
                  smarthost = "smtp.purelymail.com:587";
                  auth_username = "me@msfjarvis.dev";
                  auth_identity = "me@msfjarvis.dev";
                  send_resolved = true;
                  headers = {
                    Subject = ''{{ if .CommonAnnotations.summary }}{{ .CommonAnnotations.summary }}{{ else }}Alert: {{ or .CommonLabels.alertname "UnknownAlert" }} on {{ if .CommonLabels.target }}{{ .CommonLabels.target }}{{ else }}unknown{{ end }}{{ end }}'';
                  };
                  inherit (email) text;
                }
              ];
            }
            {
              name = "telegram";
              telegram_configs = [
                {
                  api_url = "https://api.telegram.org";
                  bot_token = "$BOT_TOKEN";
                  chat_id = 211931420;
                  parse_mode = "Markdown";
                  message = telegram.text;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
