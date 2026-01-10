{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.postgres;
  prometheusPort = lib.${namespace}.ports.exporters.postgres;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.postgres = {
    enable = mkEnableOption "PostgreSQL database server";
  };
  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
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
    sops.secrets.r2-postgres-env = {
      sopsFile = lib.snowfall.fs.get-file "secrets/restic/r2-postgresql-auth.env";
      format = "dotenv";
    };
    services.restic.backups.postgresql = {
      initialize = true;
      repository = "s3:https://07d4cd9cc7e8077fcafc5dd2fc30391b.r2.cloudflarestorage.com/${config.networking.hostName}-postgresql-backup";
      passwordFile = config.sops.secrets.restic_repo_password.path;
      environmentFile = config.sops.secrets.r2-postgres-env.path;
      paths = [ config.services.postgresqlBackup.location ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 2"
        "--keep-monthly 1"
      ];
    };
  };
}
