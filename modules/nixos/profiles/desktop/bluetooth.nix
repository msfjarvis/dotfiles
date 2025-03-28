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
  options.profiles.${namespace}.desktop.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth hardware support";
  };
  config = mkIf cfg.bluetooth.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };
}
