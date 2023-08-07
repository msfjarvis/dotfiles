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
    extraGroups = ["wheel"];
  };

  programs.command-not-found.enable = false;

  networking = {
    hostName = "crusty";
    networkmanager.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
    firewall = {
      allowedTCPPorts = [
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

  services.getty.autologinUser = "msfjarvis";

  services.openssh.enable = true;

  services.tailscale.enable = true;

  services.transmission = {
    enable = true;
    settings.watch-dir-enabled = true;
    settings.start-added-torrents = true;
    settings.trash-original-torrent-files = true;
    settings.rpc-bind-address = "0.0.0.0";
    settings.rpc-whitelist = "100.*";
    settings.rpc-host-whitelist = "100.*";
    settings.rpc-host-whitelist-enabled = true;
    user = "msfjarvis";
    downloadDirPermissions = "770";
  };

  system.stateVersion = "23.11";
}
