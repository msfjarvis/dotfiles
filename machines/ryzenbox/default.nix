{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  profiles.tailscale.enable = true;
  profiles.desktop.enable = true;
  profiles.desktop.android-dev.enable = true;
  profiles.desktop.gnome3.enable = true;
  profiles.desktop.noise-cancelation.enable = true;

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_lqx;

  home-manager.users.msfjarvis = {
    programs.mpv = {
      enable = true;
      package =
        pkgs.wrapMpv (pkgs.mpv-unwrapped.override {
          waylandSupport = true;
          x11Support = false;
          cddaSupport = false;
          vulkanSupport = false;
          drmSupport = false;
          archiveSupport = false;
          bluraySupport = false;
          bs2bSupport = false;
          cacaSupport = false;
          cmsSupport = false;
          dvdnavSupport = false;
          dvbinSupport = false;
          jackaudioSupport = false;
          javascriptSupport = false;
          libpngSupport = false;
          openalSupport = false;
          pulseSupport = false;
          pipewireSupport = true;
          rubberbandSupport = false;
          screenSaverSupport = false;
          sdl2Support = true;
          sixelSupport = false;
          speexSupport = false;
          swiftSupport = false;
          theoraSupport = false;
          vaapiSupport = true;
          vapoursynthSupport = false;
          vdpauSupport = true;
          xineramaSupport = false;
          xvSupport = false;
          zimgSupport = false;
        }) {
          scripts = with pkgs.mpvScripts; [
            uosc
            thumbfast
            inhibit-gnome
          ];
        };
      config = {
        autofit = "100%x100%";
      };
    };
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
      firefox
      fzf
      gallery-dl
      gdrive
      git-crypt
      helix
      nerdfonts
      katbin
      kondo
      maestro
      megatools
      mullvad
      mullvad-vpn
      patreon-dl
      pidcat
      psst
      (python311.withPackages (ps: with ps; [beautifulsoup4 black requests virtualenv]))
      scrcpy
      sshfs
      telegram-desktop
      thunderbird
      tuba
      webcord
      xdotool
      yt-dlp

      # Minecraft
      (prismlauncher.override {
        jdks = [temurin-bin-21];
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

  services.gphotos-cdp = {
    enable = true;
    session-dir = "/home/msfjarvis/harsh-sess";
    dldir = "/home/msfjarvis/harsh-photos";
    user = "msfjarvis";
    group = "users";
  };

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
