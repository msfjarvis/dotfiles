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
    groups.miniflux = {};
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
      miniflux = {
        isSystemUser = true;
        group = config.users.groups.miniflux.name;
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

  sops.secrets.atticd = {
    sopsFile = ./../../../secrets/atticd.yaml;
  };
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
    globalConfig = ''
      servers {
        metrics
      }
    '';
    virtualHosts = {
      "https://cache.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy ${config.services.atticd.settings.listen}
        '';
      };
      "https://git.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.gitea.settings.server.HTTP_PORT}
        '';
      };
      "https://${config.services.grafana.domain}" = {
        extraConfig = ''
          reverse_proxy ${config.services.grafana.addr}:${toString config.services.grafana.port}
        '';
      };
      "https://read.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy ${toString config.services.miniflux.config.LISTEN_ADDR}
        '';
      };
      "https://til.msfjarvis.dev" = {
        extraConfig = ''
          root * /var/lib/file_share
          file_server browse
        '';
      };
      "https://wailord.tiger-shark.ts.net" = {
        extraConfig = ''
          root * /var/lib/file_share_internal
          file_server browse
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

  services.grafana = {
    enable = true;
    domain = "grafana.msfjarvis.dev";
    port = 2342;
    addr = "127.0.0.1";
  };

  sops.secrets.feed-auth = {
    owner = config.users.users.miniflux.name;
    sopsFile = ../../../secrets/feed-auth.env;
    format = "dotenv";
  };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:8889";

      FETCH_ODYSEE_WATCH_TIME = 1;
      FETCH_YOUTUBE_WATCH_TIME = 1;
      LOG_DATE_TIME = 1;
      LOG_FORMAT = "json";
      WORKER_POOL_SIZE = 2;
      BASE_URL = "https://read.msfjarvis.dev/";
      HTTPS = 1;
      METRICS_COLLECTOR = 1;
      WEBAUTHN = 1;
    };
    adminCredentialsFile = config.sops.secrets.feed-auth.path;
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "wailord";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = ["127.0.0.1:2019"];
          }
        ];
      }
      {
        job_name = "miniflux";
        static_configs = [
          {
            targets = [config.services.miniflux.config.LISTEN_ADDR];
          }
        ];
      }
    ];
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
