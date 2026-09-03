{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) tailnetDomain;
in
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  hardware.facter.detected.graphics.enable = false;

  boot = {
    # Only enable for first installation
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  networking.hostName = "melody";
  topology.self.name = "oracle server";
  time.timeZone = "Asia/Kolkata";

  profiles.${namespace} = {
    server = {
      enable = true;
      adapterName = "enp0s6";
      tailscaleExitNode = true;
    };
    gallery-dl.enable = true;
  };

  users = {
    mutableUsers = false;
    users.msfjarvis = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2";
    };
  };

  programs.command-not-found.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpeg_8-headless
    megatools
    pkgs.llm-agents.pi
  ];

  sops.secrets.bookorbit = {
    sopsFile = lib.snowfall.fs.get-file "secrets/bookorbit.env";
    format = "dotenv";
  };

  services.${namespace} = {
    atticd = {
      enable = true;
      domain = "nix-cache";
    };

    bookorbit = {
      enable = true;
      environmentFile = config.sops.secrets.bookorbit.path;
      domain = "books.msfjarvis.dev";
    };

    calibre-web = {
      enable = false;
    };

    geoipupdate = {
      enable = true;
    };

    golink = {
      enable = true;
    };

    lurker = {
      enable = true;
      domain = "lurker";
    };

    ncps = {
      enable = false;
    };

    phanpy = {
      enable = true;
      domain = "fedi.msfjarvis.dev";
    };

    postgres = {
      enable = true;
    };

    prometheus = {
      enable = true;
    };

    prometheus-blackbox = {
      enable = true;
      targets = [
        # "https://msfjarvis.dev"
        # "https://git.msfjarvis.dev"
        # "https://grafana.msfjarvis.dev"
        # "https://money.msfjarvis.dev"
        # "https://read.msfjarvis.dev"
        # "https://vault.msfjarvis.dev"
      ];
    };

    remote-pi-relay = {
      enable = false;
      domain = "pi-relay";
      listenAddress = "127.0.0.1";
      logLevel = "info";
    };

    restic-rest-server = {
      enable = true;
      domain = "restic-melody";
      prometheusRepository = "pocket-id";
    };
  };

  services.restic.backups.lurker = {
    initialize = true;
    repository = "rest:https://restic-wailord.${tailnetDomain}/lurker";
    passwordFile = config.sops.secrets.restic_repo_password.path;
    paths = [ config.services.${namespace}.lurker.dataDir ];
    backupPrepareCommand = "${pkgs.systemd}/bin/systemctl stop podman-lurker.service";
    backupCleanupCommand = "${pkgs.systemd}/bin/systemctl start podman-lurker.service";

    pruneOpts = [
      "--keep-daily 5"
      "--keep-weekly 1"
      "--keep-monthly 1"
    ];
  };

  services.caddy = {
    enable = true;
    applyDefaults = true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
