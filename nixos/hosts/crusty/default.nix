{
  lib,
  pkgs,
  ...
}: {
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
  programs.mosh.enable = true;

  networking = {
    hostName = "crusty";
    networkmanager.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    libraspberrypi
    raspberrypi-eeprom
    megatools
    micro
    usbutils
    wirelesstools
  ];

  services.atuin = {
    enable = true;
    openRegistration = true;
    path = "";
    host = "0.0.0.0";
    port = 8888;
    openFirewall = true;
    database.createLocally = true;
  };

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

  services.rucksack = {
    enable = true;
    user = "root";
    group = "root";
    sources = [
      "/var/lib/qbittorrent/downloads"
    ];
    target = "/media/.omg";
    file_filter = "*.mp4";
  };

  services.getty.autologinUser = "msfjarvis";

  services.openssh.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    extraConfig = ''
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/media/.omg";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "msfjarvis";
        "force group" = "transmission";
      };
    };
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.qbittorrent = {
    enable = true;
    port = 9091;
    openFirewall = true;
  };

  system.stateVersion = "23.11";
}
