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
    ./minecraft.nix
    ./noise-cancelation.nix
    ./restic.nix
  ];
  options.profiles.${namespace}.desktop = {
    enable = mkEnableOption "Profile for desktop machines (i.e. not servers)";
  };
  config = mkIf cfg.enable {
    # Use latest kernel by default.
    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
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
      image = inputs.wallpaper;
      polarity = "dark";
      opacity = {
        terminal = 0.6;
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
  };
}
