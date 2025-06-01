{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) ports;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-facter-modules.nixosModules.facter
    { config.facter.reportPath = ./facter.json; }
  ];

  topology.self.name = "HomeLab PC";

  time.timeZone = "Asia/Kolkata";

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
    server = {
      enable = true;
      adapterName = "eno1";
      tailscaleExitNode = true;
    };
  };

  networking.hostName = "matara";

  environment.systemPackages = with pkgs; [
    ffmpeg_7-headless
    git
    megatools
    micro
    usbutils
    yt-dlp
  ];

  sops.secrets.services-tsauthkey-env = {
    sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    owner = config.services.caddy.user;
  };
  services.caddy = {
    enable = true;
    enableReload = false;
    package = pkgs.${namespace}.caddy-with-plugins;
    environmentFile = config.sops.secrets.services-tsauthkey-env.path;
    virtualHosts = {
      "https://matara.tiger-shark.ts.net" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.${namespace}.qbittorrent.port}
        '';
      };
      "https://matara-files.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/matara-files
          reverse_proxy ${config.services.copyparty.settings.i}:${config.services.copyparty.settings.p}
        '';
      };
      "https://stash.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/stash
          reverse_proxy ${config.services.stash.settings.host}:${toString config.services.stash.settings.port}
        '';
      };
    };
  };

  services.copyparty = {
    enable = true;
    package = pkgs.copyparty.override {
      withHashedPasswords = true;
      withCertgen = false;
      withThumbnails = false;
      withFastThumbnails = false;
      withMediaProcessing = false;
      withBasicAudioMetadata = false;
      withZeroMQ = false;
      withFTPS = true;
      withSMB = false;
    };
    mkHashWrapper = true;
    user = "msfjarvis";
    group = "users";
    settings = {
      i = "127.0.0.1";
      p = toString ports.copyparty;
    };
    volumes = {
      "/media" = {
        path = "/media/.omg";
        access = {
          "rwmd" = "*";
        };
      };
      "/mediahell" = {
        path = "/mediahell";
        access = {
          "rwmd" = "*";
        };
      };
    };
  };

  services.restic.backups = {
    photos = {
      initialize = true;
      repository = "rest:https://restic.tiger-shark.ts.net/photos";
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ config.services.${namespace}.gphotos-cdp.dldir ];

      pruneOpts = [
        "--keep-daily 2"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
  };

  services.stash = {
    enable = true;
    user = "msfjarvis";
    group = "users";
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
  # Stash module is stupid and unconditionally sets this
  users.users.msfjarvis.isSystemUser = lib.mkForce false;

  services.${namespace} = {
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
    prometheus = {
      enable = true;
    };
    qbittorrent = {
      enable = true;
      port = ports.qbittorrent;
      user = "msfjarvis";
      group = "users";
      openFirewall = true;
      prometheus.enable = true;
    };
  };

  system.stateVersion = "24.05";
}
