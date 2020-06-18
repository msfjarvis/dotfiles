# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  masterTarball =
    fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/cec5c9cf897502a444d3843f7a0aaaa852bd3fe2.tar.gz";

in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable non-free packages, and add an `latest` reference to use packages
  # from the nixpkgs master branch.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      latest = import masterTarball { config = config.nixpkgs.config; };
      custom = import customTarball { };
    };
  };

  fileSystems."/".options = [ "noatime" ];

  # Use the latest available kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable the rtl8821ce module
  boot.extraModulePackages = with config.boot.kernelPackages;
    [
      (rtl8821ce.overrideAttrs (old: {
        version = "5.5.2_34066.20200325";
        src = pkgs.fetchFromGitHub {
          owner = "tomaspinho";
          repo = "rtl8821ce";
          rev = "69765eb288a8dfad3b055b906760b53e02ab1dea";
          sha256 = "17jiw25k74kv5lnvgycvj2g1n06hbrpjz6p4znk4a62g136rhn4s";
        };
      }))
    ];

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

  # Configure fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      latest.cascadia-code
      custom.jetbrains-mono-nerdfonts
      latest.noto-fonts
      latest.roboto
      latest.ubuntu_font_family
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
    latest.bind
    latest.busybox
    latest.clang_10
    latest.cmake
    latest.curl
    latest.file
    latest.htop
    latest.ldns
    latest.llvmPackages_10.bintools
    latest.lsb-release
    latest.networkmanager
    latest.ninja
    latest.openssl_1_1
    latest.plata-theme
    latest.python38
    latest.python38Packages.python-fontconfig
    latest.traceroute
    latest.wget
    latest.wireguard
    latest.wireguard-go
    latest.wireguard-tools
    latest.unzip
    latest.xclip
    latest.xorg.xhost
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

  # Enable browserpass
  programs.browserpass.enable = true;

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

  # Install udev packages
  services.udev.packages = with pkgs; [
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
  users.users.msfjarvis.packages = with pkgs; [
    latest.android-udev-rules
    latest.aria2
    latest.asciinema
    latest.bandwhich
    latest.bat
    latest.browserpass
    latest.caddy
    latest.cargo-edit
    latest.cargo-release
    latest.cargo-sweep
    latest.cargo-update
    latest.diskus
    latest.du-dust
    latest.exa
    latest.fd
    latest.figlet
    latest.fontconfig
    latest.fzf
    latest.gitAndTools.diff-so-fancy
    latest.gitAndTools.gh
    latest.gitAndTools.git-crypt
    latest.gitAndTools.git-extras
    latest.gitAndTools.hub
    latest.git
    latest.glow
    latest.gnome3.gnome-shell-extensions
    latest.gnome3.gnome-tweaks
    latest.gnumake
    (latest.google-chrome.overrideAttrs(old: {
      sha256 = "16rmzyzjmxmhmr5yqbzqbwf5sq94iqcwlm04fkafiwcycd17nyhs";
      sha256bin64 = "0wjmc1wdmwiq9d1f5gk4c9jkj1p116kaz9nb0hvhjf01iv07xl2m";
      version = "85.0.4168.2";
    }))
    latest.hugo
    latest.hyperfine
    latest.jq
    latest.mosh
    latest.nano
    latest.ncdu
    latest.ncspot
    latest.neo-cowsay
    latest.neofetch
    latest.nixfmt
    latest.nodejs-13_x
    latest.pass
    latest.patchelf
    latest.procs
    latest.ripgrep
    latest.rustup
    latest.sass
    latest.shellcheck
    latest.shfmt
    latest.starship
    latest.tdesktop
    latest.vscode
    latest.zoxide
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

  system.copySystemConfiguration = true;
}
