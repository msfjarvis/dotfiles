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
in
{
  options.profiles.${namespace}.gallery-dl = {
    enable = mkEnableOption "gallery-dl";
  };
  config = mkIf cfg.enable {
    sops.secrets.gallery-dl-config = {
      sopsFile = lib.snowfall.fs.get-file "secrets/gallery-dl-config.yaml";
      owner = "msfjarvis";
      group = "users";
      mode = "0440";
    };
    environment.etc."gallery-dl.conf".source = config.sops.secrets.gallery-dl-config.path;
    environment.systemPackages = [ pkgs.${namespace}.gallery-dl-unstable ];
  };
}
