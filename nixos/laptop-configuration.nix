{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/8d450b25de13.tar.gz";

in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable non-free packages, and add an `latest` reference to use packages
  # from the nixpkgs-unstable branch.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      latest = import unstableTarball { config = config.nixpkgs.config; };
      custom = import customTarball { };
    };
  };

  # Setting noatime in the fstab greatly improves filesystem performance.
  fileSystems."/".options = [ "noatime" ];

  # Use the latest stable kernel.
  boot.kernelPackages = pkgs.latest.linuxPackages_latest;

  # Enable NTFS support.
  boot.supportedFilesystems = [ "ntfs" ];

  # Enable the rtl8821ce module, and override the version to the latest.
  # This is easier than having to wait for nixpkgs to merge pull requests.
  boot.extraModulePackages = with config.boot.kernelPackages;
    [
      (rtl8821ce.overrideAttrs (old: {
        version = "5.5.2_34066.20200325";
        src = pkgs.fetchFromGitHub {
          owner = "tomaspinho";
          repo = "rtl8821ce";
          rev = "14b536f0c9ad2d0abbdab8afc7ade684900ca9cf";
          sha256 = "0z7r7spsgn22gwv9pcmkdjn9ingi8jj7xkxasph8118h46fw8ip2";
        };
      }))
    ];

  # Set some cmdline options for the AMDGPU driver.
  boot.kernelParams = [ "amd_iommu=pt" "ivrs_ioapic[32]=00:14.0" "iommu=soft" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking settings.
  networking = {
    nameservers = [ "::1" ];
    hostName = "jarvisbox";
    resolvconf.dnsExtensionMechanism = false;
    networkmanager.dns = "none";
    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
  };

  # Set i18n properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Configure fonts.
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs.latest; [
      cascadia-code
      pkgs.custom.jetbrains-mono-nerdfonts
      noto-fonts
      roboto
      ubuntu_font_family
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Jetbrains Mono Nerd Font Mono Regular" ];
      };
    };
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs.latest; [
    busybox
    clang_11
    cmake
    curl
    file
    htop
    llvmPackages_11.bintools
    lsb-release
    networkmanager
    ninja
    openssl_1_1
    python38
    python38Packages.pip
    python38Packages.python-fontconfig
    sqlite
    tree
    wget
    wireguard-tools
    unzip
    xclip
    xorg.xhost
  ];

  # Make sure ~/bin is in $PATH.
  environment.homeBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  # Enable browserpass.
  programs.browserpass.enable = true;

  # Enable TLP.
  services.tlp.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Disable the resolved service.
  services.resolved.enable = false;

  # Enable PCSC-Lite daemon for use with my Yubikey.
  services.pcscd.enable = true;

  # Configure dnscrypt-proxy with the Cloudflare DoH resolver and dnsmasq to work alongside.
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:43" ];
      ipv6_servers = true;
      require_dnssec = true;
      server_names = [
        "adguard"
        "cloudflare"
        "google"
        "google-ipv6"
        "nextdns"
        "nextdns-ipv6"
      ];
      static."adguard".stamp =
        "sdns://AQIAAAAAAAAAFDE3Ni4xMDMuMTMwLjEzMDo1NDQzINErR_JS3PLCu_iZEIbq95zkSV2LFsigxDIuUso_OQhzIjIuZG5zY3J5cHQuZGVmYXVsdC5uczEuYWRndWFyZC5jb20";
      static."cloudflare".stamp =
        "sdns://AgcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5";
      static."google".stamp =
        "sdns://AgUAAAAAAAAABzguOC44LjigHvYkz_9ea9O63fP92_3qVlRn43cpncfuZnUWbzAMwbkgdoAkR6AZkxo_AEMExT_cbBssN43Evo9zs5_ZyWnftEUKZG5zLmdvb2dsZQovZG5zLXF1ZXJ5";
      static."google-ipv6".stamp =
        "sdns://AgUAAAAAAAAAFlsyMDAxOjQ4NjA6NDg2MDo6ODg4OF2gHvYkz_9ea9O63fP92_3qVlRn43cpncfuZnUWbzAMwbkgdoAkR6AZkxo_AEMExT_cbBssN43Evo9zs5_ZyWnftEUKZG5zLmdvb2dsZQovZG5zLXF1ZXJ5";
      static."nextdns".stamp =
        "sdns://AgcAAAAAAAAACjQ1LjkwLjI4LjAgPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDgOZG5zLm5leHRkbnMuaW8PL2Ruc2NyeXB0LXByb3h5";
      static."nextdns-ipv6".stamp =
        "sdns://AgcAAAAAAAAADVsyYTA3OmE4YzA6Ol0gPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDgOZG5zLm5leHRkbnMuaW8PL2Ruc2NyeXB0LXByb3h5";
    };
  };
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "127.0.0.1#43" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;
  networking.hosts = { "192.168.1.39" = [ "ryzenbox" ]; };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system and additional services for GNOME Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
    layout = "us";
    videoDrivers = [ "amdgpu" ];
  };

  # Configure Ryzen and AMDGPU.
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Install udev packages
  services.udev.packages = with pkgs; [
    android-udev-rules
    libu2f-host
    gnome3.gnome-settings-daemon
  ];

  # Stuff for gnome-shell-extensions to work properly.
  services.gnome3.chrome-gnome-shell.enable = true;

  # Disable services for faster boot times.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.msfjarvis = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networking" ]; # Enable ‘sudo’ for the user.
  };

  # User-specific packages for me, myself and I.
  users.users.msfjarvis.packages = with pkgs.latest; [
    pkgs.custom.adx
    aria2
    asciinema
    bandwhich
    bat
    browserpass
    cargo-edit
    cargo-update
    cargo-watch
    direnv
    diskus
    dnscontrol
    fd
    fontconfig
    fzf
    gitAndTools.diff-so-fancy
    gitAndTools.gh
    gitAndTools.git-absorb
    gitAndTools.git-crypt
    gitAndTools.hub
    git
    gnome3.gnome-shell-extensions
    gnome3.gnome-tweaks
    gnumake
    go
    google-chrome
    gron
    hugo
    hyperfine
    imagemagick
    jq
    pkgs.custom.lychee
    mosh
    micro
    mpv
    ncdu
    ncspot
    neofetch
    nixfmt
    nodejs-14_x
    oathToolkit
    pass
    patchelf
    procs
    ripgrep
    rustup
    shellcheck
    shfmt
    starship
    tdesktop
    vivid
    vscode
    zoxide
  ];

  system.stateVersion = "20.09";
  system.defaultChannel = "https://nixos.org/channels/nixpkgs-unstable";

  system.copySystemConfiguration = true;
}
