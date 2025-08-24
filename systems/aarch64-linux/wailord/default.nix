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
      listen = "127.0.0.1:${toString ports.atticd}";
      garbage-collection = {
        interval = "1 hour";
        default-retention-period = "14 days";
      };
    };
  };

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
      "https://metube.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/metube
          reverse_proxy 127.0.0.1:${toString ports.metube}
        '';
      };
      "https://money.msfjarvis.dev" = {
        extraConfig = ''
          import blackholeCrawlers
          encode gzip zstd
          reverse_proxy ${config.services.actual.settings.hostname}:${toString config.services.actual.settings.port}
        '';
      };
      "https://nix-cache.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/nix-cache
          plausible {
            domain_name nix-cache.tiger-shark.ts.net
            base_url https://stats.msfjarvis.dev
          }
          reverse_proxy ${config.services.atticd.settings.listen}
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

  services.actual = {
    enable = true;
    settings = {
      hostname = "127.0.0.1";
      port = ports.actual;
    };
  };

  services.${namespace} = {
    alps = {
      enable = true;
      domain = "mail";
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
      settings = (import ./glance.nix { port = ports.glance; }) // {
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
      grafana.enable = true;
    };

    restic-rest-server.enable = true;

    vaultwarden = {
      enable = true;
      domain = "vault.msfjarvis.dev";
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
