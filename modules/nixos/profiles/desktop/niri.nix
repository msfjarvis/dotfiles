{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop.niri;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.niri = {
    enable = mkEnableOption "Niri wayland compositor";
  };
  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
