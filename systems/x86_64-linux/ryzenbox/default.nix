{
  lib,
  pkgs,
  config,
  inputs,
  namespace,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  topology.self.name = "Desktop";

  profiles.${namespace} = {
    bitwarden.enable = true;
    tailscale.enable = true;
    desktop.enable = true;
    desktop.android-dev.enable = true;
    desktop.gaming.enable = true;
    desktop.gnome3.enable = true;
    desktop.noise-cancelation.enable = true;
    gallery-dl.enable = true;
  };

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Enable networking
  networking = {
    hostName = "ryzenbox";
    nftables.enable = true;
    # KDEConnect needs these ports
    firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [
      pkgs.${namespace}.adbear
      age
      attic-client
      pkgs.${namespace}.boop-gtk
      pkgs.${namespace}.cyberdrop-dl
      fclones
      ffmpeg_7-full
      (inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin.override {
        cfg = {
          smartcardSupport = true;
          pipewireSupport = true;
        };
      })
      forge-sparks
      fzf
      pkgs.${namespace}.gdrive
      git-crypt
      handbrake
      nerdfonts
      pkgs.${namespace}.katbin
      kondo
      maestro
      megatools
      newsflash
      nix-init
      nix-update
      nurl
      pkgs.${namespace}.patreon-dl
      pkgs.${namespace}.pidcat
      (python312.withPackages (
        ps: with ps; [
          beautifulsoup4
          black
          requests
          virtualenv
        ]
      ))
      scrcpy
      smile
      telegram-desktop
      thunderbird
      tuba
      vesktop
      yt-dlp
    ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  sops.secrets.restic_minecraft_repo_url = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/repo.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  sops.secrets.restic_photos_repo_url = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/repo.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  sops.secrets.restic_screenshots_repo_url = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/repo.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  sops.secrets.restic_repo_password = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/password.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  services.restic.backups = {
    minecraft = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_minecraft_repo_url.path;
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ "${config.users.users.msfjarvis.home}/Games/PrismLauncher/instances" ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 2"
        "--keep-monthly 10"
      ];
    };
    photos = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_photos_repo_url.path;
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ config.services.${namespace}.gphotos-cdp.dldir ];

      pruneOpts = [
        "--keep-daily 2"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
    screenshots = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_screenshots_repo_url.path;
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ "/mediahell/screenshots" ];

      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
  };

  services.${namespace} = {
    gphotos-cdp = {
      enable = true;
      session-dir = "/home/msfjarvis/harsh-sess";
      dldir = "/home/msfjarvis/harsh-photos";
      user = "msfjarvis";
      group = "users";
    };
    rucksack =
      let
        inherit (config.users.users.msfjarvis) home;
        minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
      in
      {
        enable = true;
        sources = [
          (minecraft "Fabulously.Optimized.1.20.6")
          (minecraft "Fabulously.Optimized.1.21")
          (minecraft "Fabulously.Optimized.1.21.1")
          "${home}/Pictures/Screenshots"
        ];
        target = "/mediahell/screenshots/";
        file_filter = "*.png";
        user = "msfjarvis";
        group = "users";
      };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
