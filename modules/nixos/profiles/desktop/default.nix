{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib) mkDefault mkEnableOption mkIf;
in
{
  imports = [
    ./android-dev.nix
    ./bluetooth.nix
    ./cinnamon.nix
    ./earlyoom.nix
    ./gaming.nix
    ./gnome3.nix
    ./noise-cancelation.nix
  ];
  options.profiles.${namespace}.desktop = {
    enable = mkEnableOption "Profile for desktop machines (i.e. not servers)";
  };
  config = mkIf cfg.enable {
    # Use latest kernel by default.
    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

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
      xserver = {
        enable = mkDefault true;

        # Configure keymap in X11
        xkb = {
          layout = mkDefault "us";
          variant = mkDefault "";
        };
      };
    };

    # Theming
    stylix = {
      autoEnable = false;
      enable = true;
      image = inputs.wallpaper;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
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
          package = pkgs.nerd-fonts.jetbrains-mono;
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
        nixos-icons.enable = true;
      };
    };

    # Enable PCSC-Lite daemon for use with my Yubikey.
    services.pcscd.enable = true;

    programs.adb.enable = true;
    services.udev.packages = [
      pkgs.android-udev-rules
      pkgs.libu2f-host
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    snowfallorg.users.msfjarvis.home.config = {
      stylix = {
        targets = {
          bat.enable = true;
          fzf.enable = true;
        };
      };
    };
  };
}
