{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.postgres;
  prometheusPort = 9004;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.postgres = {
    enable = mkEnableOption "PostgreSQL database server";
  };
  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };
    services.postgresqlBackup = {
      enable = true;
      backupAll = true;
      compression = "zstd";
    };
    services.prometheus = {
      exporters = {
        postgres = {
          enable = true;
          port = prometheusPort;
          runAsLocalSuperUser = true;
        };
      };
      scrapeConfigs = [
        {
          job_name = "postgres_exporter";
          static_configs = [ { targets = [ "127.0.0.1:${toString prometheusPort}" ]; } ];
        }
      ];
    };
  };
}
