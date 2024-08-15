{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    # Only enable for first installation
    # loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  topology.self.name = "netcup server";

  profiles.${namespace} = {
    server = {
      enable = true;
      tailscaleExitNode = true;
    };
  };
  networking.hostName = "wailord";

  time.timeZone = "Asia/Kolkata";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    groups.miniflux = { };
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
      };
      miniflux = {
        isSystemUser = true;
        group = config.users.groups.miniflux.name;
      };
    };
  };

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    attic
    megatools
  ];

  sops.secrets.atticd = {
    sopsFile = lib.snowfall.fs.get-file "secrets/atticd.yaml";
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

  sops.secrets.tsauthkey-env = {
    sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    owner = config.services.caddy.user;
  };
  services.caddy = {
    enable = true;
    package = pkgs.jarvis.caddy-tailscale;
    environmentFile = config.sops.secrets.tsauthkey-env.path;
    globalConfig = ''
      servers {
        metrics
      }
      tailscale {
        ephemeral true
      }
    '';
    extraConfig = ''
      (blackholeCrawlers) {
        @ban_crawler header_regexp User-Agent "(AdsBot-Google|Amazonbot|anthropic-ai|Applebot|Applebot-Extended|AwarioRssBot|AwarioSmartBot|Bytespider|CCBot|ChatGPT-User|ClaudeBot|Claude-Web|cohere-ai|DataForSeoBot|Diffbot|FacebookBot|FriendlyCrawler|Google-Extended|GoogleOther|GPTBot|img2dataset|ImagesiftBot|magpie-crawler|Meltwater|omgili|omgilibot|peer39_crawler|peer39_crawler/1.0|PerplexityBot|PiplBot|scoop.it|Seekr|YouBot)"
        handle @ban_crawler {
          redir https://ash-speed.hetzner.com/10GB.bin 307
        }
      }
    '';
    virtualHosts = {
      "https://cash.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/cash
          root * ${config.services.firefly-iii.package}/public
          file_server
          php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket}
        '';
      };
      "https://git.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy :${toString config.services.gitea.settings.server.HTTP_PORT}
        '';
      };
      "https://${config.services.grafana.settings.server.domain}" = {
        extraConfig = ''
          bind tailscale/grafana
          tailscale_auth
          reverse_proxy ${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port} {
            header_up X-Webauth-User {http.auth.user.tailscale_user}
          }
        '';
      };
      "https://metube.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/metube
          reverse_proxy :9090
        '';
      };
      "https://prometheus.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/prometheus
          tailscale_auth
          reverse_proxy :${toString config.services.prometheus.port} {
            header_up X-Webauth-User {http.auth.user.tailscale_user}
          }
        '';
      };
      "https://nix-cache.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/nix-cache
          reverse_proxy ${config.services.atticd.settings.listen}
        '';
      };
      "https://read.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy ${toString config.services.miniflux.config.LISTEN_ADDR}
        '';
      };
      "https://restic.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/restic
          reverse_proxy ${config.services.restic.server.listenAddress}
        '';
      };
      "https://til.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
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

  sops.secrets.firefly-iii = {
    sopsFile = lib.snowfall.fs.get-file "secrets/firefly-iii.yaml";
    owner = config.services.firefly-iii.user;
    group = config.services.firefly-iii.group;
  };
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_ENV = "production";
      APP_URL = "https://cash.tiger-shark.ts.net";
      APP_KEY_FILE = config.sops.secrets.firefly-iii.path;
      DB_CONNECTION = "sqlite";
      LOG_CHANNEL = "syslog";
      TZ = config.time.timeZone;
    };
    user = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  services.gitea = {
    enable = true;
    appName = "Harsh Shandilya's Git hosting";
    settings = {
      mailer = {
        ENABLED = false;
      };
      other = {
        SHOW_FOOTER_POWERED_BY = false;
      };
      repository = {
        DISABLE_STARS = false;
      };
      server = {
        DISABLE_SSH = true;
        DOMAIN = "git.msfjarvis.dev";
        ENABLE_GZIP = true;
        LANDING_PAGE = "explore";
        ROOT_URL = "https://git.msfjarvis.dev/";
      };
      service = {
        COOKIE_SECURE = true;
        DISABLE_REGISTRATION = true;
      };
      ui = {
        DEFAULT_THEME = "catppuccin-mocha-mauve";
      };
    };
  };

  services.restic.server = {
    enable = true;
    extraFlags = [ "--no-auth" ];
    listenAddress = "127.0.0.1:8082";
  };

  sops.secrets.gitout-config = {
    sopsFile = lib.snowfall.fs.get-file "secrets/gitout.yaml";
    owner = "msfjarvis";
  };
  services.${namespace} = {
    betula = {
      enable = true;
      domain = "links.msfjarvis.dev";
    };

    gitout = {
      enable = true;
      config-file = config.sops.secrets.gitout-config.path;
      destination-dir = "/home/msfjarvis/gitout";
      user = "msfjarvis";
      group = "users";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      "auth.proxy" = {
        enabled = true;
        auto_sign_up = false;
        enable_login_token = false;
      };
      server = {
        domain = "grafana.tiger-shark.ts.net";
        http_addr = "127.0.0.1";
        http_port = 2342;
      };
    };
  };

  sops.secrets.feed-auth = {
    owner = config.users.users.miniflux.name;
    sopsFile = lib.snowfall.fs.get-file "secrets/feed-auth.env";
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

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    compression = "zstd";
  };

  sops.secrets.restic_repo_password = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/password.yaml";
    owner = "prometheus";
    group = "prometheus";
  };
  services.prometheus = {
    enable = true;
    port = 9001;
    extraFlags = [ "--web.enable-admin-api" ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      systemd = {
        enable = true;
        port = 9003;
      };
      postgres = {
        enable = true;
        port = 9004;
        runAsLocalSuperUser = true;
      };
      restic = {
        enable = true;
        port = 9005;
        repository = "rest:http://${config.services.restic.server.listenAddress}/";
        passwordFile = config.sops.secrets.restic_repo_password.path;
        user = "prometheus";
        group = "prometheus";
      };
    };
    scrapeConfigs = [
      {
        job_name = "wailord";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ]; }
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}" ]; }
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.restic.port}" ]; }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
      }
      {
        job_name = "miniflux";
        static_configs = [ { targets = [ config.services.miniflux.config.LISTEN_ADDR ]; } ];
      }
    ];
  };

  system.stateVersion = "23.11";

  virtualisation.oci-containers.containers = {
    metube = {
      image = "ghcr.io/alexta69/metube";
      ports = [ "127.0.0.1:9090:8081" ];
      volumes = [ "/var/lib/metube:/downloads" ];
    };
  };
}
