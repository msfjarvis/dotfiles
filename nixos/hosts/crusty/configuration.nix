{
  lib,
  pkgs,
  ...
}: let
  defaultPkgs = import ../../modules/default-packages.nix;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users.users.msfjarvis = {
    isNormalUser = true;
    extraGroups = ["transmission" "wheel"];
  };

  programs.command-not-found.enable = false;

  networking = {
    hostName = "crusty";
    networkmanager.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
    firewall = {
      allowedTCPPorts = [
        80
        443
        9091
      ];
    };
  };

  nix = {
    settings = {
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io/"
        "https://nix-community.cachix.org/"
        "https://msfjarvis.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "msfjarvis.cachix.org-1:/sKPgZblk/LgoOKtDgMTwvRuethILGkr/maOvZ6W11U="
      ];
      trusted-users = ["msfjarvis" "root"];
      extra-experimental-features = ["nix-command" "flakes"];
    };
  };

  environment.systemPackages = with pkgs;
    [
      alejandra
      aria2
      byobu
      git
      libraspberrypi
      raspberrypi-eeprom
      micro
      usbutils
      wirelesstools
    ]
    ++ (defaultPkgs pkgs);

  services.atuin = {
    enable = true;
    openRegistration = true;
    path = "";
    host = "0.0.0.0";
    port = 8888;
    openFirewall = true;
    database.createLocally = true;
  };

  services.cachix-agent.enable = true;

  services.caddy = {
    enable = true;
    virtualHosts = {
      "crusty.tiger-shark.ts.net" = {
        extraConfig = ''
          encode gzip
          root * /srv/healthchecks-dashboard
          file_server
        '';
      };
    };
  };

  services.file-collector = {
    enable = true;
    user = "msfjarvis";
    group = "users";
    sources = [
      "/var/lib/transmission/Downloads"
    ];
    target = "/media/.omg";
    file_filter = "*.mp4";
  };

  services.getty.autologinUser = "msfjarvis";

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.transmission = {
    enable = true;
    credentialsFile = "/etc/extra-transmission-settings";
    downloadDirPermissions = "770";
    settings = {
      idle-seeding-limit = 5;
      idle-seeding-limit-enabled = true;
      ratio-limit = 0;
      ratio-limit-enabled = true;
      rpc-bind-address = "0.0.0.0";
      rpc-username = "msfjarvis";
      rpc-whitelist = "127.0.0.1,100.*.*.*";
      rpc-host-whitelist = "crusty,crusty.tiger-shark.ts.net";
      rpc-host-whitelist-enabled = true;
      rpc-whitelist-enabled = true;
      start-added-torrents = true;
      trash-original-torrent-files = true;
      upload-limit-enabled = true;
      watch-dir-enabled = false;
    };
    user = "msfjarvis";
  };

  system.stateVersion = "23.11";
}
