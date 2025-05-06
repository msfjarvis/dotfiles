{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-facter-modules.nixosModules.facter
    {
      facter.reportPath = ./facter.json;
      facter.detected.graphics.enable = false;
    }
  ];

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
      adapterName = "enp3s0";
      tailscaleExitNode = true;
    };
  };
  networking.hostName = "wailord";

  time.timeZone = "Asia/Kolkata";

  # The server has a weak CPU, so always offload to a remote builder
  nix.settings.max-jobs = lib.mkForce 0;

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

    megatools
  ];

  sops.secrets.atticd = {
    sopsFile = lib.snowfall.fs.get-file "secrets/atticd.yaml";
  };
  services.atticd = {
    enable = true;
    package = pkgs.attic-server;
    environmentFile = config.sops.secrets.atticd.path;

    settings = {
      listen = "[::]:8081";
      garbage-collection = {
        interval = "1 hour";
        default-retention-period = "14 days";
      };
    };
  };

  services.atuin = {
    enable = true;
    openRegistration = true;
    path = "";
    # This needs to be 0.0.0.0 so that it's accessible
    # by the rest of the tailnet
    host = "0.0.0.0";
    port = 8888;
    openFirewall = true;
    database.createLocally = true;
  };

  sops.secrets.services-tsauthkey-env = {
    sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    owner = config.services.caddy.user;
  };
  services.caddy = {
    enable = true;
    enableReload = false; # I think caddy-tailscale breaks this
    package = pkgs.${namespace}.caddy-with-plugins;
    environmentFile = config.sops.secrets.services-tsauthkey-env.path;
    logFormat = ''
      output file /var/log/caddy/caddy_main.log {
        roll_size 100MiB
        roll_keep 5
        roll_keep_for 100d
      }
      format json
      level INFO
    '';
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
        defender drop {
          ranges vpn aws deepseek githubcopilot gcloud azurepubliccloud openai mistral vultr digitalocean linode
        }
      }
    '';
    virtualHosts = {
      "https://fedi.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          root * ${pkgs.${namespace}.phanpy}
          file_server
        '';
      };
      "https://glance.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/glance
          reverse_proxy 127.0.0.1:${toString config.services.${namespace}.glance.settings.server.port}
        '';
      };
      "https://mail.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/mail
          reverse_proxy ${config.services.alps.bindIP}:${toString config.services.alps.port}
        '';
      };
      "https://metube.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/metube
          reverse_proxy 127.0.0.1:9090
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
      "https://stats.msfjarvis.dev" =
        let
          p = config.services.plausible.server;
        in
        {
          extraConfig = ''
            import blackholeCrawlers
            reverse_proxy ${p.listenAddress}:${toString p.port}
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

  sops.secrets.plausible-secret = {
    sopsFile = lib.snowfall.fs.get-file "secrets/plausible.yaml";
  };
  sops.secrets.plausible-smtp-pass = {
    sopsFile = lib.snowfall.fs.get-file "secrets/plausible.yaml";
  };
  services.plausible = {
    enable = true;
    server = {
      baseUrl = "https://stats.msfjarvis.dev";
      secretKeybaseFile = config.sops.secrets.plausible-secret.path;
    };
    mail = {
      email = "reports@stats.msfjarvis.dev";
      smtp = {
        enableSSL = true;
        hostAddr = "smtp.purelymail.com";
        hostPort = 587;
        passwordFile = config.sops.secrets.plausible-smtp-pass.path;
        user = "me@msfjarvis.dev";
      };
    };
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

    glance = {
      enable = true;
      user = "msfjarvis";
      group = "users";
      settings = {
        server = {
          host = "localhost";
          port = 8080;
        };
        # Refresh every 5 minutes
        branding = {
          logo-url = "https://msfjarvis.dev/favicon.ico";
          favicon-url = "https://msfjarvis.dev/favicon.ico";
          custom-footer = "<script>if (pageData.slug === 'home')setTimeout(() => location.reload(), 60 * 1000 * 5);</script>";
        };
        theme = {
          background-color = "240 21 15";
          contrast-multiplier = 1.2;
          primary-color = "217 92 83";
          positive-color = "115 54 76";
          negative-color = "347 70 65";
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "lobsters";
                    sort-by = "hot";
                  }
                  {
                    type = "group";
                    widgets = [
                      {
                        type = "reddit";
                        subreddit = "hermitcraft";
                        style = "vertical-list";
                        show-thumbnails = true;
                        sort-by = "top";
                        top-period = "day";
                      }
                      {
                        type = "reddit";
                        subreddit = "hermitcraftmemes";
                        style = "vertical-list";
                        show-thumbnails = true;
                        sort-by = "top";
                        top-period = "week";
                      }
                    ];
                  }
                  {
                    type = "videos";
                    cache = "15m";
                    channels = [
                      "UClu2e7S8atp6tG2galK9hgg"
                      "UC9lJXqw4QZw-HWaZH6sN-xw"
                      "UC4O9HKe9Jt5yAhKuNv3LXpQ"
                      "UCFKDEp9si4RmHFWJW1vYsMA"
                      "UCuQYHhF6on6EXXO-_i_ClHQ"
                      "UCUBsjvdHcwZd3ztdY1Zadcw"
                      "UCR9Gcq0CMm6YgTzsDxAxjOQ"
                      "UCuMJPFqazQI4SofSFEd-5zA"
                      "UCrEtZMErQXaSYy_JDGoU5Qw"
                      "UCcJgOennb0II4a_qi9OMkRA"
                      "UChFur_NwVSbUozOcF_F2kMg"
                      "UC1GJ5aeqpEWklMBQ3oXrPQQ"
                      "UCDpdtiUfcdUCzokpRWORRqA"
                      "UCodkNmk9oWRTIYZdr_HuSlg"
                      "UCYdXHOv7srjm-ZsNsTcwbBw"
                      "UC4qdHN4zHhd4VvNy3zNgXPA"
                      "UC4YUKOBld2PoOLzk0YZ80lw"
                      "UCU9pX8hKcrx06XfOB-VQLdw"
                      "UCPK5G4jeoVEbUp5crKJl6CQ"
                      "UCjI5qxhtyv3srhWr60HemRw"
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "New Delhi, India";
                  }
                  {
                    type = "releases";
                    cache = "15m";
                    repositories = [
                      "thunderbird/thunderbird-android"
                      "UweTrottmann/SeriesGuide"
                      "JetBrains/Kotlin"
                      "Kotlin/kotlinx.serialization"
                      "Kotlin/kotlinx.coroutines"
                      "square/anvil"
                      "tailscale/tailscale"
                    ];
                  }
                  {
                    type = "clock";
                    hour-format = "12h";
                    timezones = [
                      {
                        timezone = "Asia/Tokyo";
                        label = "JST";
                      }
                      {
                        timezone = "Europe/London";
                        label = "UTC";
                      }
                      {
                        timezone = "America/Los_Angeles";
                        label = "Rot sellers";
                      }
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  { type = "calendar"; }
                  {
                    type = "twitch-channels";
                    cache = "1m";
                    collapse-after = 10;
                    channels = [
                      "atrioc"
                      "couriway"
                      "feinberg"
                      "geega"
                      "kqsii"
                      "laynalazar"
                      "mintcastella"
                      "projektmelody"
                    ];
                  }
                ];
              }
            ];
          }
          {
            name = "Services";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Attic cache";
                        url = "https://nix-cache.tiger-shark.ts.net";
                        icon = "si:dask";
                      }
                      {
                        title = "Git mirror";
                        url = "https://git.msfjarvis.dev";
                        icon = "si:gitea";
                      }
                      {
                        title = "Grafana";
                        url = "https://grafana.tiger-shark.ts.net";
                        icon = "si:grafana";
                        alt-status-codes = [ 401 ];
                      }
                      {
                        title = "Private file share";
                        url = "https://wailord.tiger-shark.ts.net";
                        icon = "si:files";
                      }
                      {
                        title = "Public file share";
                        url = "https://til.msfjarvis.dev";
                        icon = "si:files";
                      }
                      {
                        title = "Prometheus (matara)";
                        url = "https://prom-matara.tiger-shark.ts.net";
                        icon = "si:prometheus";
                      }
                      {
                        title = "Prometheus (melody)";
                        url = "https://prom-melody.tiger-shark.ts.net";
                        icon = "si:prometheus";
                      }
                      {
                        title = "Prometheus (wailord)";
                        url = "https://prom-wailord.tiger-shark.ts.net";
                        icon = "si:prometheus";
                      }
                      {
                        title = "QBittorrent";
                        url = "https://matara.tiger-shark.ts.net";
                        icon = "si:qbittorrent";
                      }
                      {
                        title = "RSS reader";
                        url = "https://read.msfjarvis.dev";
                        icon = "si:rss";
                      }
                      {
                        title = "Vaultwarden";
                        url = "https://vault.msfjarvis.dev";
                        icon = "si:vaultwarden";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    postgres.enable = true;

    prometheus = {
      enable = true;
      enableGrafana = true;
    };

    restic-rest-server.enable = true;

    vaultwarden = {
      enable = true;
      domain = "https://vault.msfjarvis.dev";
    };
  };

  services.alps = {
    enable = true;
    port = 9006;
    bindIP = "127.0.0.1";
    theme = "alps";
    imaps = {
      port = 993;
      host = "imap.purelymail.com";
    };
    smtps = {
      port = 465;
      host = "smtp.purelymail.com";
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
  services.prometheus.scrapeConfigs = [
    {
      job_name = "miniflux";
      static_configs = [ { targets = [ config.services.miniflux.config.LISTEN_ADDR ]; } ];
    }
  ];

  system.stateVersion = "23.11";

  virtualisation.oci-containers.containers = {
    metube = {
      image = "ghcr.io/alexta69/metube";
      ports = [ "127.0.0.1:9090:8081" ];
      volumes = [ "/var/lib/metube:/downloads" ];
    };
  };
}
