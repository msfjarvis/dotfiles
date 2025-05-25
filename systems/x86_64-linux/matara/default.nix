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

  services.${namespace} = {
    gphotos-cdp =
      let
        homeDir = config.users.users.msfjarvis.home;
      in
      {
        enable = true;
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
      port = 9091;
      user = "msfjarvis";
      group = "users";
      openFirewall = true;
      prometheus.enable = true;
    };
    ksmbd = {
      enable = true;
      openFirewall = true;
      shares =
        let
          mkShare = path: name: {
            inherit path;
            "read only" = false;
            browseable = "yes";
            writeable = "yes";
            "force user" = "msfjarvis";
            "force group" = "users";
            "guest ok" = "yes";
            comment = "${name} samba share.";
          };
        in
        {
          media = mkShare "/media" "Chonk Disk";
          mediahell = mkShare "/mediahell" "Less Chonk Disk";
        };
    };
  };

  system.stateVersion = "24.05";
}
