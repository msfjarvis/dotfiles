{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.wezterm;
in
{
  options.profiles.wezterm = with lib; {
    enable = mkEnableOption "Enable wezterm, a GPU-accelerated terminal emulator";
  };
  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      package = pkgs.wezterm;
      extraConfig = ''
        -- Create an empty config
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        -- Use the in-built 'Catppuccin Mocha' theme
        config.color_scheme = 'catppuccin-mocha'

        -- Disable Wayland since it causes the program to not launch
        config.enable_wayland = false

        -- Use JetBrains Mono with a smaller font size than default
        config.font = wezterm.font 'JetBrains Mono Nerd Font Mono'
        config.font_size = 10.0

        -- Set initial size
        config.initial_cols = 169
        config.initial_rows = 42

        return config
      '';
    };

    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
        binding = "<Control><Alt>t";
        command = "${lib.getExe pkgs.wezterm}";
      };
    };
  };
}
