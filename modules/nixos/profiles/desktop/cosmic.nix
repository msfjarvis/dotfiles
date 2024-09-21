{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.cosmic = {
    enable = mkEnableOption "Setup desktop with Cosmic DE";
  };
  config = mkIf cfg.cosmic.enable {
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}
