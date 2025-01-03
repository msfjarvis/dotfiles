{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.ghostty;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  # home-manager and stylix both have ghostty modules but
  # they don't handle fonts right and the theme looks wack, just stick
  # with this one.
  options.profiles.${namespace}.ghostty = {
    enable = mkEnableOption "ghostty, a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "key = value settings for ghostty";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];
    home.file."${config.xdg.configHome}/ghostty/config" = mkIf (cfg.settings != { }) {
      text = lib.generators.toINIWithGlobalSection { listsAsDuplicateKeys = true; } {
        globalSection = cfg.settings;
      };
    };
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
        binding = "<Control><Alt>t";
        command = "${lib.getExe pkgs.ghostty}";
      };
    };
  };
}
