{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sd-image.nix
  ];
  # Pi kernel does not build all modules so this allows some to be missing.
  nixpkgs.overlays = [
    (_: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];

  topology.self.name = "Raspberry Pi";

  hardware.raspberry-pi."4" = {
    apply-overlays-dtmerge.enable = true;
    pwm0.enable = true;
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;

  time.timeZone = "Asia/Kolkata";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
      };
      root.openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3WC4HKwbfVGnJzhtrWo2Ue0dnaZH1JaPu4X6VILQL6''
      ];
    };
  };

  programs.command-not-found.enable = false;

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

  systemd.services.disable-wlan-powersave = {
    description = "Disable WiFi power save";
    after = ["sys-subsystem-net-devices-wlan0.device"];
    wantedBy = ["sys-subsystem-net-devices-wlan0.device"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.iw}/bin/iw dev wlan0 set power_save off";
    };
  };

  system.stateVersion = "23.11";
}
