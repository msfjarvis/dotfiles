{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.cinnamon = {
    enable = mkEnableOption "Setup desktop with Cinnamon DE";
  };
  config = mkIf cfg.cinnamon.enable {
    services.xserver = {
      desktopManager = {
        cinnamon.enable = true;
      };
      displayManager = {
        defaultSession = "cinnamon";
        lightdm.enable = true;
      };
    };
    programs.geary.enable = false;
    environment.cinnamon.excludePackages =
      with pkgs;
      with pkgs.cinnamon;
      [
        sound-theme-freedesktop
        nixos-artwork.wallpapers.simple-dark-gray
        mint-artwork
        mint-cursor-themes
        mint-l-icons
        mint-l-theme
        mint-themes
        mint-x-icons
        mint-y-icons
        hexchat
      ];

    environment.systemPackages = with pkgs; [ xclip ];

    snowfallorg.users.msfjarvis.home.config = {
      dconf.settings = {
        # Disable sounds
        "org/cinnamon/sounds" = {
          login-enabled = false;
          logout-enabled = false;
          switch-enabled = false;
          notification-enabled = false;
          unplug-enabled = false;
          plug-enabled = false;
          tile-enabled = false;
        };
        "org/cinnamon/desktop/sound" = {
          volume-sound-enabled = false;
        };
      };
      programs.gnome-terminal = {
        enable = true;
        showMenubar = false;
        themeVariant = "system";
      };
    };
  };
}
