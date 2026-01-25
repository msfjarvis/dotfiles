{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.facter.detected.graphics.enable = false;
  hardware.facter.reportPath = ./facter.json;

  topology.self.name = "HomeLab PC";

  time.timeZone = "Asia/Kolkata";

  users = {
    mutableUsers = false;
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2";
      };
    };
  };

  profiles.${namespace} = {
    server = {
      enable = true;
      adapterName = "eno1";
      tailscaleExitNode = true;
    };
    gallery-dl.enable = true;
  };

  sops.secrets.wireless-secrets = {
    sopsFile = lib.snowfall.fs.get-file "secrets/wireless.yaml";
  };
  networking.hostName = "matara";
  networking = {
    wireless = {
      enable = true;
      secretsFile = config.sops.secrets.wireless-secrets.path;
      networks = {
        "Home 4G" = {
          pskRaw = "ext:psk_home_4g";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pkgs.${namespace}.cyberdrop-dl
    ffmpeg_7-headless
    git
    megatools
    micro
    oxipng
    usbutils
    wirelesstools
    yt-dlp
  ];

  services.caddy = {
    enable = true;
    applyDefaults = true;
    virtualHosts = {
      "https://matara.${tailnetDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.${namespace}.qbittorrent.port}
        '';
      };
    }
    // (mkTailscaleVHost "stash" ''
      reverse_proxy ${config.services.stash.settings.host}:${toString config.services.stash.settings.port}
    '');
  };

  services.restic.backups = {
    photos = {
      initialize = true;
      repository = "rest:https://restic-wailord.${tailnetDomain}/photos";
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ config.services.${namespace}.gphotos-cdp.dldir ];

      pruneOpts = [
        "--keep-daily 2"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
    screenshots = {
      initialize = true;
      repository = "rest:https://restic-wailord.tiger-shark.ts.net/screenshots";
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ "/mediahell/screenshots" ];

      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
  };

  services.stash = {
    enable = true;
    user = "msfjarvis";
    group = "users";
    pythonPackage = pkgs.python3.withPackages (p: [
      p.beautifulsoup4
      p.cloudscraper
      p.configparser
      # p.libpath
      p.lxml
      p.progressbar
      p.requests
      p.yt-dlp
      p.stashapi
    ]);
    jwtSecretKeyFile = "/home/msfjarvis/stash-jwt";
    sessionStoreKeyFile = "/home/msfjarvis/stash-sess";
    passwordFile = "/home/msfjarvis/stash-pass";
    username = "msfjarvis";
    mutableSettings = true;
    settings = {
      ui.frontPageContent = [ ];
      host = "127.0.0.1";
      port = ports.stash;
      stash = [
        {
          path = "/media/.omg";
        }
      ];
    };
  };

  services.${namespace} = {
    copyparty = {
      enable = true;
      user = "msfjarvis";
      group = "users";
      volumes = {
        "/media" = {
          path = "/media";
          access = {
            "r.wmda" = "*";
          };
        };
        "/mediahell" = {
          path = "/mediahell";
          access = {
            "r.wmda" = "*";
          };
        };
      };
    };
    gphotos-cdp =
      let
        homeDir = config.users.users.msfjarvis.home;
      in
      {
        enable = false;
        session-dir = "${homeDir}/harsh-sess";
        dldir = "${homeDir}/harsh-photos";
        user = "msfjarvis";
        group = "users";
      };
    ncps = {
      enable = false;
    };
    prometheus = {
      enable = true;
    };
    qbittorrent = {
      enable = true;
      port = ports._qbittorrent;
      user = "msfjarvis";
      group = "users";
      openFirewall = true;
      prometheus.enable = true;
    };
  };

  services.qbittorrent = {
    enable = false;
    user = "msfjarvis";
    group = "users";
    openFirewall = true;
    torrentingPort = ports.qbittorrent.torrenting;
    webuiPort = ports.qbittorrent.webui;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          AlternativeUIEnabled = true;
          AuthSubnetWhitelist = "100.64.0.0/10, 127.0.0.0/8";
          AuthSubnetWhitelistEnabled = true;
          Password_PBKDF2 = ''"@ByteArray(2Q0p4bUMuIA8E1wQCuhBWw==:7w4O/oeFRwmvp+go9fW9Za+7KsPN/4Gk2rgSYVEP3Pq8mHfX5r0ju3yMT3jLU0fOSE7OE2AjNUe9t4KbFzfVdA==)"'';
          RootFolder = "''${pkgs.vuetorrent}/share/vuetorrent";
          TrustedReverseProxiesList = "127.0.0.1";
        };
        General.Locale = "en";
      };
    };
  };

  systemd.services = {
    stash.unitConfig.RequiresMountsFor = "/media";
    qbittorrent.unitConfig.RequiresMountsFor = "/media";
    copyparty.unitConfig.RequiresMountsFor = "/media";
  };

  system.stateVersion = "24.05";
}
