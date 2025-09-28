{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.gallery-dl;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) mkSystemSecret;
in
{
  options.profiles.${namespace}.gallery-dl = {
    enable = mkEnableOption "gallery-dl";
  };
  config = mkIf cfg.enable {
    sops.secrets.gallery-dl-config = mkSystemSecret {
      file = "gallery-dl-config";
      owner = "msfjarvis";
      group = "users";
    };
    environment.etc."gallery-dl.conf".source = config.sops.secrets.gallery-dl-config.path;
    environment.systemPackages = [ pkgs.${namespace}.gallery-dl-unstable ];
  };
}
