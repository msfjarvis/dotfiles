{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) ports tailnetDomain mkTailscaleVHost;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  hardware.facter.detected.graphics.enable = false;

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
        hashedPassword = "$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2";
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
    host = "127.0.0.1";
    port = ports.atuin;
    openFirewall = false;
    database.createLocally = true;
  };

  services.caddy = {
    enable = true;
    applyDefaults = true;
    virtualHosts = {
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
    }
    // (mkTailscaleVHost "atuin" ''
      reverse_proxy 127.0.0.1:${toString ports.atuin}
    '')
    // (mkTailscaleVHost "metube" ''
      reverse_proxy 127.0.0.1:${toString ports.metube}
    '');
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
      enable = false;
      domain = "nix-cache";
    };

    betula = {
      enable = true;
      domain = "links.msfjarvis.dev";
    };

    caldav-api = {
      enable = true;
    };

    forgejo = {
      enable = true;
      domain = "git.msfjarvis.dev";
    };

    geoipupdate = {
      enable = true;
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

    ncps = {
      enable = false;
    };

    paperless-ngx = {
      enable = true;
      domain = "papers.msfjarvis.dev";
    };

    pocket-id = {
      enable = true;
      domain = "auth.msfjarvis.dev";
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
      prometheusRepository = null;
    };

    umami = {
      enable = true;
      domain = "stats01.msfjarvis.dev";
    };

    vaultwarden = {
      enable = true;
      domain = "vault.msfjarvis.dev";
      backvault.enable = false;
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
