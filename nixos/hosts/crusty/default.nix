{
  config,
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

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    users.msfjarvis = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = ''$y$j9T$MQNdrYiBEX4.vkTzuXc4Q.$FKzWf0o.527za6LfMU1f96Cf2iZPZRVmOwmOw7yx5.A'';
    };
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
        5357 # wsdd
      ];
      allowedUDPPorts = [
        3702 # wsdd
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
    yt-dlp
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

  services.getty.autologinUser = "msfjarvis";

  services.openssh.enable = true;

  services.qbittorrent = {
    enable = true;
    port = 9091;
    openFirewall = true;
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

  services.samba-wsdd.enable = true;
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
        "force user" = "${toString config.services.qbittorrent.user}";
        "force group" = "${toString config.services.qbittorrent.group}";
      };
    };
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.tailscale-autoconnect = {
    enable = true;
    authkeyFile = "/run/secrets/tsauthkey";
    extraOptions = ["--accept-risk=lose-ssh" "--ssh"];
  };

  system.stateVersion = "23.11";
}
