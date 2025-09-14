{
  pkgs,
  inputs,
  namespace,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    inputs.nixos-facter-modules.nixosModules.facter
    {
      facter.reportPath = ./facter.json;
      facter.detected.graphics.enable = false;
    }
  ];

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
  };

  users = {
    mutableUsers = false;
    users.msfjarvis = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
    };
  };

  programs.command-not-found.enable = true;

  environment.systemPackages = with pkgs; [
    ffmpeg_7-headless
    megatools
  ];

  services.${namespace} = {
    ncps = {
      enable = true;
    };

    prometheus = {
      enable = true;
    };

    prometheus-blackbox = {
      enable = true;
      targets = [
        "https://msfjarvis.dev"
        "https://git.msfjarvis.dev"
        "https://grafana.msfjarvis.dev"
        "https://money.msfjarvis.dev"
        "https://read.msfjarvis.dev"
        "https://vault.msfjarvis.dev"
      ];
    };

    golink = {
      enable = true;
    };

    restic-rest-server = {
      enable = true;
      domain = "restic-melody";
      prometheusRepository = "pocket-id";
    };
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
