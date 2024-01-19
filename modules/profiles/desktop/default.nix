{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
in {
  imports = [./android-dev.nix ./cinnamon.nix ./gnome3.nix];
  options.profiles.desktop = with lib; {
    enable = mkEnableOption "Profile for desktop machines (i.e. not servers)";
  };
  config = lib.mkIf cfg.enable {
    # Use latest kernel by default.
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

    sound.enable = false;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

    services = {
      # Enable the X11 windowing system.
      xserver = with lib; {
        enable = mkDefault true;

        # Configure keymap in X11
        layout = mkDefault "us";
        xkbVariant = mkDefault "";
      };

      # Enable CUPS to print documents.
      printing.enable = lib.mkDefault true;
    };

    hardware = {bluetooth.enable = lib.mkDefault true;};

    # Theming
    stylix = {
      autoEnable = false;
      image = pkgs.fetchurl {
        url = "https://msfjarvis.dev/images/wallpaper.png";
        sha256 = "sha256-GoF4dZTt/+rDrp1Z7+lY/8doSzqiqyXikR1gXDyxkQg=";
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
      };

      fonts = {
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
        monospace = {
          name = "JetBrainsMonoNL Nerd Font Mono Regular";
          package = pkgs.nerdfonts;
        };
        sansSerif = {
          name = "Roboto Regular";
          package = pkgs.roboto;
        };
        serif = {
          name = "Roboto Serif 20pt Regular";
          package = pkgs.roboto-serif;
        };
        sizes = {
          applications = 12;
          terminal = 10;
        };
      };
      opacity = {
        terminal = 0.6;
      };
      polarity = "dark";
      targets = {
        console.enable = true;
      };
    };

    programs.adb.enable = true;
    services.udev.packages = [
      pkgs.android-udev-rules
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    home-manager.users.msfjarvis = {
      programs.mpv.enable = true;
      stylix = {
        targets = {
          bat.enable = true;
          fzf.enable = true;
        };
      };
    };
  };
}
