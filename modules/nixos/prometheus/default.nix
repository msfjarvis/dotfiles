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
          reverse_proxy 127.0.0.1:${toString config.services.prometheus.port} {
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
    services.loki = {
      enable = true;
      configuration = {
        # Basic stuff
        auth_enabled = false;
        server = {
          http_listen_port = 3100;
          log_level = "warn";
        };
        common = {
          path_prefix = config.services.loki.dataDir;
          storage.filesystem = {
            chunks_directory = "${config.services.loki.dataDir}/chunks";
            rules_directory = "${config.services.loki.dataDir}/rules";
          };
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
          ring.instance_addr = "127.0.0.1";
        };

        ingester.chunk_encoding = "snappy";

        limits_config = {
          retention_period = "120h";
          ingestion_burst_size_mb = 16;
          reject_old_samples = true;
          reject_old_samples_max_age = "12h";
        };

        table_manager = {
          retention_deletes_enabled = true;
          retention_period = "120h";
        };

        compactor = {
          retention_enabled = true;
          compaction_interval = "10m";
          working_directory = "${config.services.loki.dataDir}/compactor";
          delete_request_cancel_period = "10m"; # don't wait 24h before processing the delete_request
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };

        schema_config.configs = [
          {
            from = "2020-11-08";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index.prefix = "index_";
            index.period = "24h";
          }
        ];

        query_range.cache_results = true;
        limits_config.split_queries_by_interval = "24h";
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
    services.promtail = {
      enable = false; # Haven't figured out how to allow it to read Caddy logs
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "caddy";
            static_configs = [
              {
                targets = [
                  "localhost"
                ];
                labels = {
                  job = "caddy";
                  __path__ = "/var/log/caddy/*log";
                  agent = "caddy-promtail";
                };
              }
            ];
            pipeline_stages = [
              {
                json = {
                  expressions = {
                    duration = "duration";
                    status = "status";
                  };
                };
              }
              {
                labels = {
                  duration = null;
                  status = null;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
