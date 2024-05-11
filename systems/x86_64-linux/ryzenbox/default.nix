{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  topology.self.name = "Desktop";

  profiles.tailscale.enable = true;
  profiles.desktop.enable = true;
  profiles.desktop.android-dev.enable = true;
  profiles.desktop.gnome3.enable = true;
  profiles.desktop.noise-cancelation.enable = true;

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

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
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "ryzenbox";
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
    ];
    packages = with pkgs; [
      age
      attic
      jarvis.boop-gtk
      discord
      fclones
      (ffmpeg.override {
        buildFfplay = false;
        buildFfprobe = true;
        buildQtFaststart = false;
        withAom = true;
        withAss = true;
        withDav1d = true;
        withDrm = true;
        withMp3lame = true;
        withNvdec = true;
        withNvenc = true;
        withRav1e = true;
        withVaapi = true;
        withVdpau = true;
        withVorbis = true;
        withVpx = true;
        withWebp = true;
        withX264 = true;
        withX265 = true;
      })
      (inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin.override {
        cfg = {
          smartcardSupport = true;
          pipewireSupport = true;
        };
      })
      fzf
      gallery-dl
      jarvis.gdrive
      git-crypt
      helix
      nerdfonts
      jarvis.katbin
      kondo
      maestro
      megatools
      mullvad
      mullvad-vpn
      newsflash
      nix-init
      nix-update
      jarvis.patreon-dl
      jarvis.pidcat
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
      sshfs
      telegram-desktop
      thunderbird
      tuba
      uv
      xdotool
      yt-dlp

      # Minecraft
      mcaselector
      (prismlauncher.override {
        jdks = [ openjdk22 ];
        withWaylandGLFW = config.profiles.desktop.gnome3.enable;
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
  programs.nix-ld.libraries = with pkgs; [
    icu
    openssl
    stdenv.cc.cc
    zlib
  ];

  services.glance = {
    enable = true;
    configFile = "~/glance.yml";
    user = "msfjarvis";
    group = "users";
  };

  services.gphotos-cdp = {
    enable = true;
    session-dir = "/home/msfjarvis/harsh-sess";
    dldir = "/home/msfjarvis/harsh-photos";
    user = "msfjarvis";
    group = "users";
  };

  services.rucksack =
    let
      inherit (config.users.users.msfjarvis) home;
      minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
    in
    {
      enable = true;
      sources = [
        (minecraft "1.21")
        (minecraft "ACLU SMP Modpack")
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
