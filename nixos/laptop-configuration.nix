# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Fetch the latest copy of the nixos-unstable channel.
let unstableTarball = fetchTarball https://github.com/msfjarvis/nixpkgs/archive/nixos-unstable.tar.gz;

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable non-free packages, and add an unstable reference to use packages
  # from the NixOS unstable channel.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Use the latest available kernel.
  boot.kernelPackages = pkgs.linuxPackages_4_19;

  # Enable the rtl8821ce module
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];

  # Set come cmdline options for AMDGPU
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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bind
    busybox
    cmake
    curl
    htop
    networkmanager
    ninja
    plata-theme
    python38
    python38Packages.python-fontconfig
    traceroute
    wget
    wireguard
    wireguard-go
    wireguard-tools
    unzip
    xclip
  ];

  # Make sure ~/bin is in $PATH.
  environment.homeBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  #   enableSSHSupport = true;
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
  udev.packages = [ pkgs.libu2f-host ];

  # Configure dnscrypt-proxy with the Cloudflare DoH resolver and dnsmasq to work alongside.
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:43" ];
      ipv6_servers = true;
      require_dnssec = true;
      server_names = [ "cloudflare" ];
      static."cloudflare".stamp = "sdns://AgEAAAAAAAAACjQ1LjkwLjI4LjAADmRucy5uZXh0ZG5zLmlvBy9iMTFkM2I";
    };
  };
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "127.0.0.1#43" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
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
    videoDrivers = [ "amdgpu" ];
  };

  # Configure Ryzen and AMDGPU
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the GNOME Desktop Environment.
  services.gvfs.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

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
  users.users.msfjarvis.packages = with pkgs; [
    android-udev-rules
    aria2
    asciinema
    bandwhich
    bat
    browserpass
    cargo
    cargo-audit
    cargo-bloat
    cargo-deps
    cargo-edit
    cargo-outdated
    cargo-release
    cargo-sweep
    cargo-update
    chrome-gnome-shell
    gitAndTools.diff-so-fancy
    gitAndTools.git-crypt
    diskus
    du-dust
    exa
    fd
    figlet
    fontconfig
    fzf
    gitAndTools.gh
    git
    glow
    gnome3.gnome-shell-extensions
    gnome3.gnome-tweaks
    gnumake
    google-chrome-beta
    gitAndTools.hub
    hugo
    hyperfine
    jq
    mosh
    nano
    ncdu
    neofetch
    pass
    patchelf
    procs
    ripgrep
    tdesktop
    shellcheck
    shfmt
    spotify
    starship
    vscode
    unstable.zoxide
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
