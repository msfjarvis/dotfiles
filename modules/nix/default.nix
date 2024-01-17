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

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    package = pkgs.nixUnstable;

    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      experimental-features = nix-command flakes recursive-nix
      keep-outputs = true
      warn-dirty = false
      keep-derivations = true
    '';
    settings = {
      flake-registry = "/etc/nix/registry.json";
      auto-optimise-store = true;
      builders-use-substitutes = true;
      allowed-users = ["@wheel"];
      trusted-users = ["@wheel" "msfjarvis"];
      sandbox = true;
      max-jobs = "auto";
      keep-going = true;
      log-lines = 20;
      extra-experimental-features = ["flakes" "nix-command" "recursive-nix" "ca-derivations"];

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
