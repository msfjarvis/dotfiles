{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    # Only enable for first installation
    # loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  topology.self.name = "netcup server";

  profiles.server.enable = true;
  profiles.server.tailscaleExitNode = true;
  networking.hostName = "wailord";

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
        openssh.authorizedKeys.keys = [
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K''
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3WC4HKwbfVGnJzhtrWo2Ue0dnaZH1JaPu4X6VILQL6''
        ];
      };
      root.openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3WC4HKwbfVGnJzhtrWo2Ue0dnaZH1JaPu4X6VILQL6''
      ];
    };
  };

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    git
    micro
  ];

  services.atticd = {
    enable = true;
    credentialsFile = config.sops.secrets.atticd.path;

    settings = {
      listen = "[::]:8081";
      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

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
      "https://git.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.gitea.settings.server.HTTP_PORT}
        '';
      };
      "https://wailord.tiger-shark.ts.net" = {
        extraConfig = ''
          root * /var/lib/file_share_internal
          file_server browse
        '';
      };
      "https://read.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy ${toString config.services.yarr.addr}
        '';
      };
      "https://til.msfjarvis.dev" = {
        extraConfig = ''
          root * /var/lib/file_share
          file_server browse
        '';
      };
      "https://toot.msfjarvis.dev" = {
        extraConfig = ''
          root * ${inputs.nixpkgs-news.packages.${pkgs.system}.nixpkgs-news}
          file_server
        '';
      };
    };
  };

  services.gitea = {
    enable = true;
    appName = "Harsh Shandilya's Git hosting";
    settings = {
      mailer.ENABLED = false;
      server.DOMAIN = "git.msfjarvis.dev";
      server.ROOT_URL = "https://git.msfjarvis.dev/";
      service.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
    };
  };

  services.yarr = {
    enable = true;
    addr = "127.0.0.1:8889";
    auth-file = config.sops.secrets.yarr-auth.path;
    db = "/var/lib/yarr/database.sqlite";
    package = pkgs.jarvis.yarr-dev;
  };

  system.stateVersion = "23.11";

  # virtualisation.oci-containers.containers = {
  #   linkding = {
  #     image = "sissbruecker/linkding:latest-alpine";
  #     ports = ["127.0.0.1:9090:9090"];
  #     volumes = ["/var/lib/linkding:/etc/linkding/data"];
  #   };
  # };
}
