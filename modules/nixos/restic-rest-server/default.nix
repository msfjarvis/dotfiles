{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.restic-rest-server;
  # Was 9005 before but that is being used by Clickhouse now
  prometheusPort = 9008;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.restic-rest-server = {
    enable = mkEnableOption "Restic REST server";
  };
  config = mkIf cfg.enable {
    services.restic.server = {
      enable = true;
      extraFlags = [ "--no-auth" ];
      listenAddress = "127.0.0.1:8082";
    };

    sops.secrets.restic_repo_password = {
      sopsFile = lib.snowfall.fs.get-file "secrets/restic/password.yaml";
      owner = "prometheus";
      group = "prometheus";
    };
    services.prometheus = {
      exporters = {
        restic = {
          enable = true;
          repository = "rest:http://${config.services.restic.server.listenAddress}/";
          passwordFile = config.sops.secrets.restic_repo_password.path;
          port = prometheusPort;
          user = "prometheus";
          group = "prometheus";
        };
      };
      scrapeConfigs = [
        {
          job_name = "restic_exporter";
          static_configs = [ { targets = [ "127.0.0.1:${toString prometheusPort}" ]; } ];
        }
      ];
    };
  };
}
