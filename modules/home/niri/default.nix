{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.niri;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.niri = {
    enable = mkEnableOption "Niri wayland compositor";
  };
  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      settings = {
        environment = {
          DISPLAY = ":0";
        };
        spawn-at-startup = [
          { command = [ (lib.getExe pkgs.xwayland-satellite) ]; }
        ];
        prefer-no-csd = true;
        window-rules = [
        ];
        binds = { };
      };
    };
  };
}
