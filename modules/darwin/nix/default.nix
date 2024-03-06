{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };

    package = pkgs.nixUnstable;

    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      keep-outputs = true
      warn-dirty = false
      keep-derivations = true
    '';
    settings = {
      accept-flake-config = true;
      allowed-users = ["msfjarvis"];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "recursive-nix"
        "repl-flake"
      ];
      flake-registry = "/etc/nix/registry.json";
      http-connections = 50;
      keep-going = true;
      log-lines = 20;
      max-jobs = "auto";
      sandbox = true;
      trusted-users = ["root" "msfjarvis"];
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
  services.nix-daemon.enable = true;
}
