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

  profiles.server.enable = true;
  networking.hostName = "crusty";

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

  services.caddy = {
    enable = true;
    virtualHosts = {
      "https://crusty.tiger-shark.ts.net" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.qbittorrent.port}
        '';
      };
    };
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

  # Disable some home-manager goodies that are pointless on servers.
  home-manager.users.msfjarvis = {
    home.file.".imwheelrc".enable = false;
    programs.browserpass.enable = false;
    programs.password-store.enable = false;
    programs.topgrade.enable = false;
    programs.vscode.enable = false;
    services.git-sync.enable = false;

    # Use a simpler prompt.
    programs.starship = {
      settings = {
        format = "$directory$git_branch$git_state$git_status➜ ";
        character.disabled = true;
      };
    };
  };
}
