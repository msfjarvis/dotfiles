{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
in {
  options.profiles.desktop.cinnamon = with lib; {
    enable = mkEnableOption "Setup desktop with Cinnamon DE";
  };
  config = lib.mkIf cfg.cinnamon.enable {
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
    environment.cinnamon.excludePackages = with pkgs;
    with pkgs.cinnamon; [
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

    home-manager.users.msfjarvis = {
      dconf.settings = {
        "org/cinnamon/theme" = {
          name = "Dracula";
        };
        "org/cinnamon/desktop/interface" = with config.stylix.fonts; {
          cursor-theme = "Bibata-Modern-Classic";
          font-name = "${sansSerif.name} ${toString sizes.applications}";
          icon-theme = "Dracula";
        };
        "org/cinnamon/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://${config.stylix.image}";
          picture-uri-dark = "file://${config.stylix.image}";
        };
        "org/gnome/desktop/interface" = with config.stylix.fonts; {
          theme = "Dracula";
          cursor-theme = "Bibata-Modern-Classic";
          icon-theme = "Dracula";
          font-name = "${sansSerif.name} ${toString sizes.applications}";
          document-font-name = "${serif.name} ${toString (sizes.applications - 1)}";
          monospace-font-name = "${monospace.name} ${toString sizes.terminal}";
        };
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
      home.sessionVariables.GTK_THEME = "Dracula";
      programs.gnome-terminal = {
        enable = true;
        showMenubar = false;
        themeVariant = "system";
        profile = {
          "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
            default = true;
            visibleName = "Dracula";
            colors = with config.lib.stylix.colors.withHashtag; {
              foregroundColor = base05;
              backgroundColor = base00;
              boldColor = base04;
              palette = [
                base00
                base01
                base02
                base03
                base04
                base05
                base06
                base07
                base08
                base09
                base0A
                base0B
                base0C
                base0D
                base0E
                base0F
              ];
            };
            boldIsBright = true;
            audibleBell = false;
          };
        };
      };
    };
  };
}
