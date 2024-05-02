{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
  };

  users.users.msfjarvis.packages = with pkgs; [
    expect
    jarvis.nix-inspect
    nix-output-monitor
  ];

  programs.nh = {
    enable = true;
    package = pkgs.jarvis.nh;
    clean.enable = true;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  nix = {
    optimise.automatic = true;

    package = pkgs.nixVersions.git;

    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      keep-outputs = true
      warn-dirty = false
      keep-derivations = true
    '';
    settings = {
      accept-flake-config = true;
      allowed-users = ["@wheel"];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = lib.mkForce [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "recursive-nix"
      ];
      flake-registry = "/etc/nix/registry.json";
      http-connections = 50;
      keep-going = true;
      log-lines = 20;
      cores = 6;
      max-jobs = 12;
      sandbox = true;
      trusted-users = ["root" "@wheel"];
      use-cgroups = true;
      warn-dirty = false;

      trusted-substituters = [
        "https://cache.garnix.io"
        "https://msfjarvis.cachix.org"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "msfjarvis.cachix.org-1:/sKPgZblk/LgoOKtDgMTwvRuethILGkr/maOvZ6W11U="
      ];
    };
  };
}
