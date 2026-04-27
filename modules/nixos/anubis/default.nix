{ config, lib, ... }:
let
  instancesWithMetrics = lib.filterAttrs (
    _name: inst: inst.settings ? METRICS_BIND
  ) config.services.anubis.instances;
in
{
  services.anubis = {
    defaultOptions = {
      enable = true;
      settings = {
        BIND_NETWORK = "tcp";
        DIFFICULTY = 5;
        METRICS_BIND_NETWORK = "tcp";
        OG_PASSTHROUGH = true;
        SERVE_ROBOTS_TXT = true;
      };
    };
  };

  services.prometheus.scrapeConfigs = lib.mapAttrsToList (name: inst: {
    job_name = "${name}_anubis";
    scrape_interval = "1m";
    static_configs = [
      {
        targets = [
          (
            let
              bind = inst.settings.METRICS_BIND;
            in
            if lib.hasPrefix ":" bind then "127.0.0.1${bind}" else bind
          )
        ];
      }
    ];
  }) instancesWithMetrics;
}
