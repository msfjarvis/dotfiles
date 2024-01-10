{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  profiles.tailscale.enable = true;
  profiles.desktop.enable = true;
  profiles.desktop.gnome3.enable = true;

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;

  home-manager.users.msfjarvis = {
    stylix = {
      targets = {
        firefox = {
          enable = true;
          profileNames = [
            "Primary"
            "Secondary"
          ];
        };
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "ryzenbox";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  services.xserver = {
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };
  };

  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      adb-sync
      adx
      age
      diffuse-bin
      dracula-icon-theme
      dracula-theme
      fclones
      ffmpeg
      firefox
      fzf
      gdrive
      git-crypt
      nerdfonts
      katbin
      kondo
      maestro
      megatools
      mullvad
      mullvad-vpn
      patreon-dl
      pidcat
      (python311.withPackages (ps: with ps; [beautifulsoup4 black requests virtualenv]))
      scrcpy
      spotify
      telegram-desktop
      thunderbird
      webcord
      xclip
      xdotool
      yt-dlp

      # Android Development
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
      (gradle_8.override {
        java = temurin-bin-20;
        javaToolchains = [temurin-bin-17 temurin-bin-20];
      })
      temurin-bin-20

      # Minecraft
      (prismlauncher.override {
        jdks = [temurin-bin-20];
      })
    ];
  };

  services.mullvad-vpn = {
    enable = true;
  };
  # Required for Mullvad
  # https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/11
  services.resolved.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
  ];

  services.rucksack = let
    inherit (config.users.users.msfjarvis) home;
    minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
  in {
    enable = true;
    sources = [
      (minecraft "1.21")
      (minecraft "Fabulously.Optimized.1.20.2")
      (minecraft "Fabulously.Optimized.MC.1.17.1")
      (minecraft "Fabulously.Optimized.MC.1.20.1")
      (minecraft "Pokemon Elysium")
      "${home}/Games/PrismLauncher/instances/Vault Hunters 3/minecraft/screenshots/"
    ];
    target = "/mediahell/screenshots/";
    file_filter = "*.png";
    user = "msfjarvis";
    group = "users";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
