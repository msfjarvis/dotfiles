{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) ports tailnetDomain;
in
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
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
      };
    };
  };

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [
    megatools
  ];

  services.atuin = {
    enable = true;
    openRegistration = false;
    path = "";
    # This needs to be 0.0.0.0 so that it's accessible
    # by the rest of the tailnet.
    # TODO: Reverse proxy this and lock it down.
    host = "0.0.0.0";
    port = ports.atuin;
    openFirewall = true;
    database.createLocally = true;
  };

  services.caddy = {
    enable = true;
    applyDefaults = true;
    virtualHosts = {
      "https://fedi.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          root * ${pkgs.${namespace}.phanpy}
          file_server
        '';
      };
      "https://metube.${tailnetDomain}" = {
        extraConfig = ''
          bind tailscale/metube
          reverse_proxy 127.0.0.1:${toString ports.metube}
        '';
      };
      "https://til.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          root * /var/lib/file_share
          file_server browse
        '';
      };
      "https://wailord.${tailnetDomain}" = {
        extraConfig = ''
          root * /var/lib/file_share_internal
          file_server browse
        '';
      };
    };
  };

  services.${namespace} = {
    actual-budget = {
      enable = true;
      domain = "money.msfjarvis.dev";
    };

    alps = {
      enable = true;
      domain = "mail";
    };

    atticd = {
      enable = true;
      domain = "nix-cache";
    };

    betula = {
      enable = true;
      domain = "links.msfjarvis.dev";
    };

    forgejo = {
      enable = true;
      domain = "git.msfjarvis.dev";
    };

    glance = {
      enable = true;
      user = "msfjarvis";
      group = "users";
      settings =
        (import ./glance.nix {
          inherit tailnetDomain;
          port = ports.glance;
        })
        // {
          server.domain = "glance";
        };
    };

    miniflux = {
      enable = true;
      domain = "read.msfjarvis.dev";
    };

    pocket-id = {
      enable = true;
      domain = "auth.msfjarvis.dev";
    };

    plausible = {
      enable = true;
      domain = "stats.msfjarvis.dev";
    };

    postgres.enable = true;

    prometheus = {
      enable = true;
      grafana = {
        enable = true;
        host = "grafana.msfjarvis.dev";
      };
    };

    restic-rest-server = {
      enable = true;
      domain = "restic-wailord";
      prometheusRepository = "";
    };

    vaultwarden = {
      enable = true;
      domain = "vault.msfjarvis.dev";
    };
  };

  services.restic.backups = {
    pocket-id = {
      initialize = true;
      repository = "rest:https://restic-melody.${tailnetDomain}/pocket-id";
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ config.services.pocket-id.dataDir ];

      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
  };

  system.stateVersion = "23.11";

  virtualisation.oci-containers.containers = {
    metube = {
      image = "ghcr.io/alexta69/metube";
      ports = [ "127.0.0.1:${toString ports.metube}:8081" ];
      volumes = [ "/var/lib/metube:/downloads" ];
    };
  };
}
