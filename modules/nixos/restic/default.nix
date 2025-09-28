{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkSystemSecret;
in
{
  config = lib.mkIf (config.services.restic.backups != { }) {
    sops.secrets.restic_repo_password = mkSystemSecret {
      file = "restic/password";
      # Default user for Restic backup services, whenever I start using
      # purpose-built users for individual backups this will need to be
      # changed.
      owner = lib.mkDefault "root";
    };
  };
}
