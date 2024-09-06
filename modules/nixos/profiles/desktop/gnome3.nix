{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib)
    catAttrs
    filter
    mkEnableOption
    mkIf
    ;
  extensionsMap = with pkgs.gnomeExtensions; [
    # Save and restore window positions
    {
      package = another-window-session-manager;
      uuid = "another-window-session-manager@gmail.com";
    }
    # A nicer application menu for gnome
    {
      package = arcmenu;
      uuid = "arcmenu@arcmenu.com";
    }
    # KDEConnect port
    {
      package = gsconnect;
      uuid = "gsconnect@andyholmes.github.io";
    }
    # Top bar media control widget
    {
      package = media-controls;
      uuid = "mediacontrols@cliffniff.github.com";
    }
    # Better tiling controls
    {
      package = tiling-shell;
      uuid = "tilingshell@ferrarodomenico.com";
    }
    # System activity indicator
    {
      package = astra-monitor;
      uuid = "monitor@astraext.github.io";
    }
    # Make top bar transparent when nothing is docked to it
    {
      package = transparent-top-bar;
      uuid = "transparent-top-bar@zhanghai.me";
    }
    # Allow controlling themes
    {
      package = user-themes;
      uuid = "user-theme@gnome-shell-extensions.gcampax.github.com";
    }
    {
      package = null;
      uuid = "native-window-placement@gnome-shell-extensions.gcampax.github.com";
    }
    {
      package = null;
      uuid = "places-menu@gnome-shell-extensions.gcampax.github.com";
    }
    {
      package = null;
      uuid = "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com";
    }
  ];
in
{
  options.profiles.${namespace}.desktop.gnome3 = {
    enable = mkEnableOption "Setup desktop with Gnome DE";
  };
  config = mkIf cfg.gnome3.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.displayManager.defaultSession = "gnome";
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Enable Wayland compatibility workarounds within Nixpkgs
    environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "x11";
    environment.variables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      wl-clipboard
      xclip
    ];

    users.users.msfjarvis.packages =
      with pkgs;
      [
        # Old GNOME picture viewer, better than the current default
        eog
        gnome-tweaks
      ]
      ++ (filter (pkg: pkg != null) (catAttrs "package" extensionsMap));
    environment.gnome.excludePackages = with pkgs; [
      epiphany
      geary
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-weather
      loupe
      simple-scan
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
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = catAttrs "uuid" extensionsMap;
          last-selected-power-profile = "performance";
        };
        "org/gnome/desktop/privacy" = {
          old-files-age = 7;
          remember-recent-files = false;
          remove-old-trash-files = true;
          remove-old-temp-files = true;
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
        "org/gnome/settings-daemon/plugins/power" = {
          power-button-action = "interactive";
          sleep-inactive-ac-type = "nothing";
        };
      };
    };
  };
}
