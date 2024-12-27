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
    attrsToList
    concatStringsSep
    map
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.profiles.${namespace}.ghostty = {
    enable = mkEnableOption "ghostty, a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "key = value settings for ghostty";
    };
    keybinds = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of keybindings to configure for ghostty";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];
    home.file."${config.xdg.configHome}/ghostty/config" = mkIf (cfg.settings != { }) {
      text = concatStringsSep "\n" (
        map (kv: "${kv.name} = ${builtins.toString kv.value}") (attrsToList cfg.settings)
        ++ map (bind: "keybind = ${bind}") cfg.keybinds
      );
    };
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
        binding = "<Control><Alt>t";
        command = "${lib.getExe pkgs.ghostty}";
      };
    };
  };
}
