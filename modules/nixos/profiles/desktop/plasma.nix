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
    mkEnableOption
    mkIf
    ;
in
{
  options.profiles.${namespace}.desktop.plasma = {
    enable = mkEnableOption "Setup desktop with KDE Plasma DE";
  };
  config = mkIf cfg.plasma.enable {
    # Enable the KDE Plasma Desktop Environment
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.defaultSession = "plasma";

    # Enable KDE's kwallet like we enabled gnome-keyring for GNOME
    services.gnome.gnome-keyring.enable = false; # Use KWallet instead
    programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    programs.kde-pim.enable = true;

    # Enable KDE Connect
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      xclip
      kdePackages.filelight # Disk usage analyzer
      kdePackages.kwalletmanager # Password manager UI
      kdePackages.kdeplasma-addons # Extra widgets
      kdePackages.plasma-browser-integration
    ];

    users.users.msfjarvis.packages = with pkgs; [
      kdePackages.kio-admin # Admin file management
      kdePackages.kcalc # Calculator
      kdePackages.kcharselect # Character selector
    ];

    # Exclude useless packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa # Music player
      oxygen # Old KDE theme
    ];

    # Enable Qt and GTK theming via stylix (NixOS level)
    stylix.targets = {
      gtk.enable = true;
    };

    snowfallorg.users.msfjarvis.home.config = {
      stylix.targets = {
        gtk = {
          enable = true;
          flatpakSupport.enable = true;
        };
      };
      gtk = {
        enable = true;
      };

      home.file = {
        # Disable file indexing
        ".config/baloofilerc".text = ''
          [Basic Settings]
          Indexing-Enabled=false
        '';

        # Desktop settings - 6 workspaces
        ".config/kwinrc".text = ''
          [Desktops]
          Number=6
          Rows=2
        '';

        # Disable screen locking (similar to GNOME idle-delay = 0)
        ".config/kscreenlockerrc".text = ''
          [Daemon]
          Autolock=false
          LockOnResume=false
        '';

        # Disable recent files
        ".config/kdeglobals".text = ''
          [RecentDocuments]
          UseRecent=false
        '';
      };
    };
  };
}
