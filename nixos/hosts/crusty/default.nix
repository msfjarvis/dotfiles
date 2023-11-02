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

  # Work around 'pq: permission denied for schema public' with postgres v15, until a
  # solution for `services.postgresql.ensureUsers` is found.
  # See https://github.com/NixOS/nixpkgs/issues/216989
  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'ALTER DATABASE atuin OWNER TO atuin;'
  '';

  system.stateVersion = "23.11";
}
