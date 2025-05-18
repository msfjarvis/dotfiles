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
      settings = import ./glance.nix;
    };

    postgres.enable = true;

    prometheus = {
      enable = true;
      grafana.enable = true;
      # TODO: start segragating these into 9_${toInt service}_xy
      alertmanager.port = 9010;
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
