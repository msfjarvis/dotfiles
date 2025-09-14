{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.prometheus-blackbox;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
  blackboxConfig = {
    modules = {
      https_2xx = {
        prober = "http";
        timeout = "5s";
        http = {
          method = "GET";
          valid_status_codes = [ ];
          fail_if_not_ssl = true;
        };
      };
    };
  };
  blackboxTargets =
    {
      job_name,
      scrape_interval,
      modules,
      targets,
    }:
    {
      inherit job_name;
      inherit scrape_interval;
      metrics_path = "/probe";
      params = {
        module = modules;
      };
      static_configs = [
        { inherit targets; }
      ];
      relabel_configs = [
        {
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          source_labels = [ ];
          target_label = "__address__";
          replacement = "127.0.0.1:${toString ports.exporters.blackbox}";
        }
      ];
    };
in
{
  options.services.${namespace}.prometheus-blackbox = {
    enable = mkEnableOption "Blackbox monitoring of specified domains";
    targets = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Domains to monitor via the blackbox exporter";
    };
  };
  config = mkIf cfg.enable {
    services.prometheus.exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = ports.exporters.blackbox;
      configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON blackboxConfig);
    };
    services.prometheus.scrapeConfigs = [
      (blackboxTargets {
        job_name = "http_probe";
        scrape_interval = "1m";
        modules = [ "https_2xx" ];
        inherit (cfg) targets;
      })
    ];
    services.prometheus.rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "blackbox_probe";
            rules = [
              {
                alert = "ProbeFailed";
                expr = "avg(probe_success) by (job, target) < 0.5";
                for = "5m";
                labels = {
                  severity = "page";
                };
                annotations = {
                  summary = "Probe {{ $labels.job }} on {{ $labels.target }} failed";
                  description = "Probe {{ $labels.job }} on {{ $labels.target }} failed for 5 minutes.";
                };
              }
              {
                alert = "ProbeTlsCertExpiringSoon";
                expr = "min(probe_ssl_earliest_cert_expiry) by (job, target) - time() < 3600 * 24 * 7";
                for = "5m";
                labels = {
                  severity = "ticket";
                };
                annotations = {
                  summary = "TLS certificate for {{ $labels.job }} on {{ $labels.target }} expiring soon";
                  description = "The TLS certificate for {{ $labels.job }} on {{ $labels.target }} expires in less than 7 days.";
                };
              }
            ];
          }
        ];
      })
    ];
  };
}
