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
      package = tophat;
      uuid = "tophat@fflewddur.github.io";
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
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Enable Wayland compatibility workarounds within Nixpkgs
    environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "x11";
    environment.variables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      wl-clipboard
      xclip
    ];
    # Required by the tophat extension
    services.xserver.desktopManager.gnome.sessionPath = with pkgs; [ libgtop ];

    users.users.msfjarvis.packages =
      with pkgs;
      [
        # Old GNOME picture viewer, better than the current default
        eog
        gnome-tweaks
      ]
      ++ (builtins.filter (pkg: pkg != null) (builtins.map (ext: ext.package) extensionsMap));
    environment.gnome.excludePackages =
      with pkgs;
      with pkgs.gnome;
      [
        epiphany
        geary
        gnome-calendar
        gnome-characters
        gnome-clocks
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
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
          let
            terminal-cmd =
              if (config.profiles.wezterm.enable or false) then
                "${lib.getExe pkgs.wezterm}"
              else
                "${lib.getExe pkgs.gnome-console}";
          in
          lib.mkDefault {
            binding = "<Control><Alt>t";
            command = terminal-cmd;
          };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = builtins.map (ext: ext.uuid) extensionsMap;
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
