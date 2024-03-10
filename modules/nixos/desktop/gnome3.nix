{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
in {
  options.profiles.desktop.gnome3 = with lib; {
    enable = mkEnableOption "Setup desktop with Gnome DE";
  };
  config = lib.mkIf cfg.gnome3.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [wl-clipboard];
    # Required by the tophat extension
    services.xserver.desktopManager.gnome.sessionPath = with pkgs; [libgtop];

    users.users.msfjarvis.packages = with pkgs;
      [
        # Old GNOME picture viewer, better than the current default
        gnome.eog
        gnome3.gnome-tweaks
      ]
      ++ (with pkgs.gnomeExtensions; [
        # A nicer application menu for gnome
        arcmenu
        # POP!_OS shell tiling extensions for Gnome 3
        pop-shell
        # Display Mullvad state
        mullvad-indicator
        # System activity indicator
        tophat
        # Allows binding apps to specific workspaces
        unmess
        # Allow controlling themes
        user-themes
      ]);
    environment.gnome.excludePackages = with pkgs; [loupe gnome.totem];

    stylix.targets = {
      gnome.enable = true;
    };

    snowfallorg.users.msfjarvis.home.config = {
      gtk = {
        enable = true;
        theme = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };
        cursorTheme = {
          name = "Dracula-cursors";
          package = pkgs.dracula-theme;
        };
      };
      dconf.settings = {
        "org/gnome/shell/extensions/user-theme" = {
          name = "Dracula";
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "arcmenu@arcmenu.com"
            "mullvadindicator@pobega.github.com"
            "pop-shell@system76.com"
            "tophat@fflewddur.github.io"
            "unmess@ezix.org"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
          ];
        };
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://${config.stylix.image}";
          picture-uri-dark = "file://${config.stylix.image}";
        };
        "org/gnome/desktop/interface" = with config.stylix.fonts; {
          cursor-theme = "Dracula-cursors";
          gtk-theme = "Dracula";
          # Taken from Stylix
          color-scheme =
            if config.stylix.polarity == "dark"
            then "prefer-dark"
            else "default";
          font-name = "${sansSerif.name} ${toString sizes.applications}";
          document-font-name = "${serif.name} ${toString (sizes.applications - 1)}";
          monospace-font-name = "${monospace.name} ${toString sizes.terminal}";
        };
        "org/gnome/desktop/notifications/application/org-gnome-console" = {
          enable = false;
        };
      };
    };
  };
}
