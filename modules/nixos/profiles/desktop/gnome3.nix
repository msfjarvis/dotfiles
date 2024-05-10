{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.desktop.gnome3 = {
    enable = mkEnableOption "Setup desktop with Gnome DE";
  };
  config = mkIf cfg.gnome3.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Enable Wayland compatibility workarounds within Nixpkgs
    environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "x11";
    environment.variables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [ wl-clipboard ];
    # Required by the tophat extension
    services.xserver.desktopManager.gnome.sessionPath = with pkgs; [ libgtop ];

    users.users.msfjarvis.packages =
      with pkgs;
      [
        # Old GNOME picture viewer, better than the current default
        gnome.eog
        gnome3.gnome-tweaks
      ]
      ++ (with pkgs.gnomeExtensions; [
        # A nicer application menu for gnome
        arcmenu
        # Tweak GNOME settings
        just-perfection
        # Top bar media control widget
        media-controls
        # POP!_OS shell tiling extensions for Gnome 3
        pop-shell
        # System activity indicator
        tophat
        # Make top bar transparent when nothing is docked to it
        transparent-top-bar
        # Allows binding apps to specific workspaces
        unmess
        # Allow controlling themes
        user-themes
      ]);
    environment.gnome.excludePackages = with pkgs.gnome; [
      epiphany
      geary
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-weather
      pkgs.loupe
      simple-scan
      pkgs.snapshot
      totem
    ];

    stylix.targets = {
      gnome.enable = true;
      gtk.enable = true;
    };

    snowfallorg.users.msfjarvis.home.config = {
      stylix.targets = {
        gtk.enable = true;
      };
      gtk = {
        enable = true;
      };
      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkDefault {
          binding = "<Control><Alt>t";
          command = "${lib.getExe pkgs.gnome-console}";
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "arcmenu@arcmenu.com"
            "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
            "just-perfection-desktop@just-perfection"
            "mediacontrols@cliffniff.github.com"
            "native-window-placement@gnome-shell-extensions.gcampax.github.com"
            "places-menu@gnome-shell-extensions.gcampax.github.com"
            "pop-shell@system76.com"
            "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
            "tophat@fflewddur.github.io"
            "transparent-top-bar@zhanghai.me"
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
          # Taken from Stylix
          color-scheme = if config.stylix.polarity == "dark" then "prefer-dark" else "default";
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
