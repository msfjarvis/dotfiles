{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/06e53dbb544a7eb427dbb4066a4f886e1681b629.tar.gz";

in {
  imports = [ ./hardware-configuration.nix ];

  # Enable non-free packages, and add an `latest` reference to use packages
  # from the nixpkgs master branch.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };

  fileSystems."/".options = [ "noatime" ];

  # Use the latest available kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking settings.
  networking = {
    nameservers = [ "::1" ];
    hostName = "ryzenbox";
    resolvconf.dnsExtensionMechanism = false;
    networkmanager.dns = "none";
    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Configure fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      cascadia-code
      custom.jetbrains-mono-nerdfonts
      noto-fonts
      roboto
      ubuntu_font_family
    ];
    fontconfig = {
      penultimate.enable = false;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Jetbrains Mono Nerd Font Mono Regular" ];
      };
    };
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bind
    busybox
    clang_10
    cmake
    curl
    file
    htop
    ldns
    llvmPackages_10.bintools
    lsb-release
    networkmanager
    ninja
    openssl_1_1
    plata-theme
    python39
    python39Packages.pip
    python39Packages.python-fontconfig
    sqlite
    traceroute
    tree
    wget
    wireguard
    wireguard-tools
    unzip
    xclip
    xorg.xhost
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Disable the resolved service.
  services.resolved.enable = false;

  # Enable PCSC-Lite daemon for use with my Yubikey.
  services.pcscd.enable = true;

  # Enable U2F support
  hardware.u2f.enable = true;

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
        "cloudflare-security"
        "cloudflare-security-ipv6"
        "decloudus-nogoogle-tst"
        "google"
        "google-ipv6"
        "nextdns"
        "nextdns-ipv6"
        "skyfighter-dns"
        "quad9-dnscrypt-ipv4-nofilter-pri"
      ];
      static."adguard".stamp =
        "sdns://AQIAAAAAAAAAFDE3Ni4xMDMuMTMwLjEzMDo1NDQzINErR_JS3PLCu_iZEIbq95zkSV2LFsigxDIuUso_OQhzIjIuZG5zY3J5cHQuZGVmYXVsdC5uczEuYWRndWFyZC5jb20";
      static."cloudflare".stamp =
        "sdns://AgcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5";
      static."cloudflare-security".stamp =
        "sdns://AgMAAAAAAAAABzEuMC4wLjIAG3NlY3VyaXR5LmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5";
      static."cloudflare-security-ipv6".stamp =
        "sdns://AgMAAAAAAAAAGlsyNjA2OjQ3MDA6NDcwMDo6MTExMl06NDQzABtzZWN1cml0eS5jbG91ZGZsYXJlLWRucy5jb20KL2Rucy1xdWVyeQ";
      static."decloudus-nogoogle-tst".stamp =
        "sdns://AQMAAAAAAAAAEjE3Ni45LjE5OS4xNTg6ODQ0MyD73Ye9XeCsS7TdFu9fRP7s5k-0aL91yygulGVmeOAKLh4yLmRuc2NyeXB0LWNlcnQuRGVDbG91ZFVzLXRlc3Q";
      static."google".stamp =
        "sdns://AgUAAAAAAAAABzguOC44LjigHvYkz_9ea9O63fP92_3qVlRn43cpncfuZnUWbzAMwbkgdoAkR6AZkxo_AEMExT_cbBssN43Evo9zs5_ZyWnftEUKZG5zLmdvb2dsZQovZG5zLXF1ZXJ5";
      static."google-ipv6".stamp =
        "sdns://AgUAAAAAAAAAFlsyMDAxOjQ4NjA6NDg2MDo6ODg4OF2gHvYkz_9ea9O63fP92_3qVlRn43cpncfuZnUWbzAMwbkgdoAkR6AZkxo_AEMExT_cbBssN43Evo9zs5_ZyWnftEUKZG5zLmdvb2dsZQovZG5zLXF1ZXJ5";
      static."nextdns".stamp =
        "sdns://AgcAAAAAAAAACjQ1LjkwLjI4LjAgPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDgOZG5zLm5leHRkbnMuaW8PL2Ruc2NyeXB0LXByb3h5";
      static."nextdns-ipv6".stamp =
        "sdns://AgcAAAAAAAAADVsyYTA3OmE4YzA6Ol0gPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDgOZG5zLm5leHRkbnMuaW8PL2Ruc2NyeXB0LXByb3h5";
      static."skyfighter-dns".stamp =
        "sdns://AQcAAAAAAAAACzUxLjE1LjYyLjY1INFr3LQKTn-quuLUnNelOU5_Pu-w6mo6-B6ljqcvmJebIjIuZG5zY3J5cHQtY2VydC5za3lmaWdodGVyLWRucy5jb20";
      static."quad9-dnscrypt-ipv4-nofilter-pri".stamp =
        "sdns://AQYAAAAAAAAADTkuOS45LjEwOjg0NDMgZ8hHuMh1jNEgJFVDvnVnRt803x2EwAuMRwNo34Idhj4ZMi5kbnNjcnlwdC1jZXJ0LnF1YWQ5Lm5ldA";
    };
  };
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "127.0.0.1#43" ];

  networking.firewall.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system and additional services for GNOME Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
  };

  # Configure Ryzen
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

  system.stateVersion = "20.09";
  system.defaultChannel = "https://nixos.org/channels/nixpkgs-unstable";
  system.copySystemConfiguration = true;
}
