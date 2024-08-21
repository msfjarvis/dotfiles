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
    enableReload = false; # I think caddy-tailscale breaks this
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
      "https://metube.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/metube
          reverse_proxy :9090
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

  sops.secrets.gitout-config = {
    sopsFile = lib.snowfall.fs.get-file "secrets/gitout.yaml";
    owner = "msfjarvis";
  };
  services.${namespace} = {
    betula = {
      enable = true;
      domain = "links.msfjarvis.dev";
    };

    gitea = {
      enable = true;
      domain = "git.msfjarvis.dev";
    };

    gitout = {
      enable = true;
      config-file = config.sops.secrets.gitout-config.path;
      destination-dir = "/home/msfjarvis/gitout";
      user = "msfjarvis";
      group = "users";
    };

    postgres.enable = true;

    prometheus.enable = true;

    restic-rest-server.enable = true;
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

  system.stateVersion = "23.11";

  virtualisation.oci-containers.containers = {
    metube = {
      image = "ghcr.io/alexta69/metube";
      ports = [ "127.0.0.1:9090:8081" ];
      volumes = [ "/var/lib/metube:/downloads" ];
    };
  };
}
