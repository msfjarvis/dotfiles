{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.wezterm;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.wezterm = {
    enable = mkEnableOption "Enable wezterm, a GPU-accelerated terminal emulator";
  };
  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      package = pkgs.wezterm;
      extraConfig = ''
        -- Create an empty config
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        -- Use the in-built 'Catppuccin Mocha' theme
        config.color_scheme = 'catppuccin-mocha'

        -- Explicitly enable Wayland support
        config.enable_wayland = true

        -- Use JetBrains Mono with a smaller font size than default
        config.font = wezterm.font 'JetBrains Mono Nerd Font Mono'
        config.font_size = 10.0

        -- Set initial size
        config.initial_cols = 169
        config.initial_rows = 42

        -- Tweak Window decorations
        config.window_background_opacity = 0.95
        config.window_decorations = 'RESIZE'
        config.window_frame = {
          font = wezterm.font 'JetBrains Mono Nerd Font Mono',
          font_size = 11.0
        }
        wezterm.on('update-status', function(window)
          -- Grab the utf8 character for the "powerline" left facing
          -- solid arrow.
          local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

          -- Grab the current window configuration, and from it the
          -- palette (this is the combination of your chosen colour scheme
          -- including any overrides).
          local color_scheme = window:effective_config().resolved_palette
          local bg = color_scheme.background
          local fg = color_scheme.foreground

          window:set_right_status(wezterm.format({
            -- First, we draw the arrow...
            { Background = { Color = 'none' } },
            { Foreground = { Color = bg } },
            { Text = SOLID_LEFT_ARROW },
            -- Then we draw our text
            { Background = { Color = bg } },
            { Foreground = { Color = fg } },
            { Text = ' ' .. wezterm.hostname() .. ' ' },
          }))
        end)

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
