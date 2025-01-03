{ config, lib, ... }:
{
  config = lib.mkIf (config.services.restic.backups != { }) {
    sops.secrets.restic_repo_password = {
      sopsFile = lib.snowfall.fs.get-file "secrets/restic/password.yaml";
      # Default user for Restic backup services, whenever I start using
      # purpose-built users for individual backups this will need to be
      # changed.
      owner = "root";
    };
  };
}
