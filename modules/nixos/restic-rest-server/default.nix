{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.restic-rest-server;
  inherit (lib.${namespace}) ports;
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
      listenAddress = "127.0.0.1:${toString ports.restic-rest-server}";
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
          port = ports.exporters.restic-rest-server;
          user = "prometheus";
          group = "prometheus";
        };
      };
      scrapeConfigs = [
        {
          job_name = "restic_exporter";
          static_configs = [ { targets = [ "127.0.0.1:${toString ports.exporters.restic-rest-server}" ]; } ];
        }
      ];
    };
  };
}
