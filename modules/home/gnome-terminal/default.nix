{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.gnome-terminal;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.gnome-terminal = {
    enable = mkEnableOption "GNOME Terminal";
  };
  config = mkIf cfg.enable {
    programs.gnome-terminal.enable = true;
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
        binding = "<Control><Alt>t";
        command = "${lib.getExe pkgs.gnome-terminal}";
      };

    };
  };
}
