{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
let
  homeDir = config.users.users.msfjarvis.home;
  inherit (lib.${namespace}) ports;
  mkSteamPath = gameId: {
    path = "${homeDir}/.local/share/Steam/userdata/896827038/760/remote/${gameId}/screenshots";
    recursive = false;
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.facter.reportPath = ./facter.json;

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
    # desktop.niri.enable = false;
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
    nftables.enable = true;
    # KDEConnect needs these ports
    firewall = {
      allowedTCPPortRanges = [
        ports.kdeconnect_range
      ];
      allowedUDPPortRanges = [
        ports.kdeconnect_range
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
      "com.spotify.Client"
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
      # Root
      "wheel"
    ];
    packages = with pkgs; [
      pkgs.${namespace}.adbear
      pkgs.${namespace}.age-keygen-deterministic
      age
      pkgs.${namespace}.boop-gtk
      calibre
      pkgs.${namespace}.cyberdrop-dl
      fclones
      ffmpeg_8-full
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
      github-copilot-cli
      google-chrome # Hotstar hates Firefox
      # ffmpeg_7-full fails to build: https://hydra.nixos.org/build/319912371/nixlog/2
      # handbrake
      pkgs.${namespace}.katbin
      kondo
      maestro
      pkgs.${namespace}.mediafire_rs
      megatools
      nix-init
      nurl
      obsidian
      opencode
      pkgs.${namespace}.patreon-dl
      pkgs.${namespace}.pidcat
      scrcpy
      telegram-desktop
      thunderbird-latest
      unrar
      uv
      (vesktop.override { withSystemVencord = true; })
      yt-dlp
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.udev.extraRules = ''
    # Disable the in-built Bluetooth adapter
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0e8d", ATTRS{idProduct}=="0616", ATTR{authorized}="0"
    # Allow access to the CoryDora macropad
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="4344", ATTRS{idProduct}=="0001", MODE="660", TAG+="uaccess", TAG+="udev-acl"
  '';

  services.${namespace} = {
    rucksack = {
      enable = false;
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
