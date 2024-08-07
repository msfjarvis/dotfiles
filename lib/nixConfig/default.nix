{
  mkNixConfig =
    {
      pkgs,
      lib,
      inputs,
    }:
    {
      package = inputs.lix.packages.${pkgs.system}.default;

      generateNixPathFromInputs = true;
      generateRegistryFromInputs = true;
      linkInputs = true;

      extraOptions = ''
        keep-outputs = true
        warn-dirty = false
        keep-derivations = true
      '';
      settings = {
        accept-flake-config = true;
        allowed-users = [ "msfjarvis" ];
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
        max-jobs = "auto";
        sandbox = true;
        trusted-users = [
          "root"
          "msfjarvis"
        ];
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
