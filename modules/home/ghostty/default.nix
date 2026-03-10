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
    ;
in
{
  options.profiles.${namespace}.ghostty = {
    enable = mkEnableOption "ghostty, a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
  };
  config = mkIf cfg.enable {
    stylix.targets.ghostty.enable = config.programs.ghostty.enable;
    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      installBatSyntax = true;
      # TODO: https://gist.github.com/jamesgecko/dd921cef7db3b9533cee4473e832f2a4
      settings = {
        cursor-click-to-move = true;
        gtk-quick-terminal-layer = "overlay";
        keybind = [
          "ctrl+shift+right=unbind"
          "ctrl+shift+left=unbind"
          "shift+end=unbind"
          "shift+home=unbind"
        ];
        maximize = true;
        notify-on-command-finish = "unfocused";
        notify-on-command-finish-action = "notify";
        palette-generate = true;
        # 512 MB in bytes
        scrollback-limit = 536870912;
        shell-integration = "bash";
        shell-integration-features = true;
        quit-after-last-window-closed = false;
        window-theme = "ghostty";
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
