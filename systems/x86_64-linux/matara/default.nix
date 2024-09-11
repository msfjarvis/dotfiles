{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  topology.self.name = "HomeLab PC";

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
        extraGroups = [ "wheel" ];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
      };
    };
  };

  profiles.${namespace} = {
    server.enable = true;
  };
  networking.hostName = "matara";

  environment.systemPackages = with pkgs; [
    git
    megatools
    micro
    usbutils
    yt-dlp
  ];

  sops.secrets.tsauthkey-env = {
    sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    owner = config.services.caddy.user;
  };
  services.caddy = {
    enable = true;
    package = pkgs.jarvis.caddy-tailscale;
    environmentFile = config.sops.secrets.tsauthkey-env.path;
    virtualHosts = {
      "https://matara.tiger-shark.ts.net" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.${namespace}.qbittorrent.port}
        '';
      };
      "https://glance.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/glance
          reverse_proxy :${toString config.services.${namespace}.glance.settings.server.port}
        '';
      };
      "https://prom-matara.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/prom-matara
          reverse_proxy :${toString config.services.prometheus.port}
        '';
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "matara";
        static_configs = [
          { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          { targets = [ "127.0.0.1:${toString config.services.${namespace}.qbittorrent.prometheus.port}" ]; }
        ];
      }
    ];
  };

  services.${namespace} = {
    glance = {
      enable = true;
      user = "msfjarvis";
      group = "users";
      settings = {
        server.port = 8080;
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
                  { type = "calendar"; }
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
                      "UCZ9x-z3iOnIbJxVpm1rsu2A"
                      "UCrEtZMErQXaSYy_JDGoU5Qw"
                      "UCcJgOennb0II4a_qi9OMkRA"
                      "UChFur_NwVSbUozOcF_F2kMg"
                      "UC1GJ5aeqpEWklMBQ3oXrPQQ"
                      "UCDpdtiUfcdUCzokpRWORRqA"
                      "UCodkNmk9oWRTIYZdr_HuSlg"
                      "UCYdXHOv7srjm-ZsNsTcwbBw"
                      "UC4qdHN4zHhd4VvNy3zNgXPA"
                      "UC24lkOxZYna9nlXYBcJ9B8Q"
                      "UC4YUKOBld2PoOLzk0YZ80lw"
                      "UCU9pX8hKcrx06XfOB-VQLdw"
                      "UCPK5G4jeoVEbUp5crKJl6CQ"
                      "UCjI5qxhtyv3srhWr60HemRw"
                    ];
                  }
                  {
                    type = "reddit";
                    subreddit = "hermitcraft";
                    style = "horizontal-cards";
                    sort-by = "top";
                    top-period = "day";
                  }
                  {
                    type = "reddit";
                    subreddit = "hermitcraftmemes";
                    style = "horizontal-cards";
                    sort-by = "top";
                    top-period = "day";
                  }
                ];
              }
              {
                size = "small";
                widgets = [
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
                        title = "RSS reader";
                        url = "https://read.msfjarvis.dev";
                        icon = "si:rss";
                      }
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
                    type = "twitch-channels";
                    cache = "1m";
                    channels = [
                      "couriway"
                      "geminitay"
                      "laynalazar"
                      "matarakan"
                      "michimochievee"
                      "mush"
                      "pearlescentmoon"
                      "sliggytv"
                    ];
                  }
                ];
              }
            ];
          }
          {
            name = "Internet";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={QUERY}";
                  }
                  {
                    type = "lobsters";
                    sort-by = "hot";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
    gphotos-cdp = {
      enable = true;
      session-dir = "/home/msfjarvis/harsh-sess";
      dldir = "/home/msfjarvis/harsh-photos";
      user = "msfjarvis";
      group = "users";
    };
    qbittorrent = {
      enable = true;
      port = 9091;
      openFirewall = true;
      prometheus.enable = true;
    };
    rucksack = {
      enable = true;
      user = "root";
      group = "root";
      sources = [ "/var/lib/qbittorrent/downloads" ];
      target = "/media/.omg";
      file_filter = "*.mp4";
    };
  };

  system.stateVersion = "23.11";
}
