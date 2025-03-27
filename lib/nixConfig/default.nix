{
  mkNixConfig =
    {
      pkgs,
      lib,
    }:
    {
      package = pkgs.lix;

      generateNixPathFromInputs = true;
      generateRegistryFromInputs = true;
      linkInputs = true;

      buildMachines = [
        {
          hostName = "melody";
          system = "aarch64-linux";
          protocol = "ssh-ng";
          maxJobs = 2;
          speedFactor = 2;
          supportedFeatures = [
            "big-parallel"
            "kvm"
          ];
          mandatoryFeatures = [ ];
        }
      ];
      distributedBuilds = true;

      extraOptions = ''
        keep-outputs = true
        warn-dirty = false
        keep-derivations = true
        builders-use-substitutes = true
      '';
      settings = {
        accept-flake-config = true;
        allowed-users = [ "msfjarvis" ];
        auto-optimise-store = true;
        builders-use-substitutes = true;
        experimental-features = lib.mkForce [
          "auto-allocate-uids"
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

        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
}
