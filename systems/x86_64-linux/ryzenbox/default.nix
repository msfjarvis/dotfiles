{
  lib,
  pkgs,
  config,
  inputs,
  namespace,
  ...
}:
let
  homeDir = config.users.users.msfjarvis.home;
  mkSteamPath = gameId: {
    path = "${homeDir}/.local/share/Steam/userdata/896827038/760/remote/${gameId}/screenshots";
    recursive = false;
  };
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-facter-modules.nixosModules.facter
    { config.facter.reportPath = ./facter.json; }
  ];

  # We use a deterministically generate SOPS key instead of re-keying based on the system SSH key
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";

  topology.self.name = "Desktop";

  profiles.${namespace} = {
    bitwarden.enable = true;
    tailscale.enable = true;
    desktop.enable = true;
    desktop.android-dev.enable = true;
    desktop.bluetooth.enable = true;
    desktop.gaming.enable = true;
    desktop.gaming.minecraft.enable = true;
    desktop.gnome3.enable = true;
    desktop.niri.enable = true;
    desktop.noise-cancelation.enable = true;
    gallery-dl.enable = true;
  };

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    memtest86.enable = true;
    windows = {
      "10" = {
        efiDeviceHandle = "HD0b";
        title = "Windows 10";
      };
    };
  };
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;

  snowfallorg.users.msfjarvis.home.config = {
    stylix = {
      targets = {
        firefox = {
          enable = true;
          profileNames = [
            "Primary"
            "Secondary"
          ];
        };
        vesktop.enable = true;
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "ryzenbox";
    networkmanager.plugins = lib.mkForce [ ];
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

  services.flatpak = {
    enable = true;
    update.auto.enable = true;
    uninstallUnmanaged = true;
    packages = [
      "io.gitlab.news_flash.NewsFlash"
    ];
  };

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = [
      # Arduino
      "dialout"
      # Virtualization
      "libvirtd"
      "networkmanager"
      # Root
      "wheel"
    ];
    packages = with pkgs; [
      pkgs.${namespace}.adbear
      pkgs.${namespace}.age-keygen-deterministic
      age

      pkgs.${namespace}.boop-gtk
      pkgs.${namespace}.cyberdrop-dl
      fclones
      ffmpeg_7-full
      (firefox-nightly-bin.override {
        cfg = {
          smartcardSupport = true;
          pipewireSupport = true;
        };
      })
      forge-sparks
      fzf
      pkgs.${namespace}.gdrive
      git-crypt
      google-chrome # Hotstar hates Firefox
      handbrake
      nerd-fonts.iosevka-term
      pkgs.${namespace}.katbin
      kondo
      maestro
      pkgs.${namespace}.mediafire_rs
      megatools
      nix-init
      nix-update
      nurl
      obsidian
      pkgs.${namespace}.patreon-dl
      pkgs.${namespace}.pidcat
      (python3.withPackages (
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
      thunderbird-latest
      unrar
      uv
      (vesktop.override { withSystemVencord = true; })
      yt-dlp
    ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.restic.backups = {
    screenshots = {
      initialize = true;
      repository = "rest:https://restic.tiger-shark.ts.net/screenshots";
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
    rucksack = {
      enable = true;
      sources = [
        "${homeDir}/Pictures/Screenshots"
        # Detroit: Become Human
        (mkSteamPath "1222140")
        # Helldivers 2
        (mkSteamPath "553850")
        # Split Fiction
        (mkSteamPath "2001120")
        # Tiny Glade
        (mkSteamPath "2198150")
      ];
      target = "/mediahell/screenshots/";
      file_filter = "*.{png,jpg}";
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
