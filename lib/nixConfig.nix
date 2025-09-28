{
  mkNixConfig =
    {
      pkgs,
      lib,
    }:
    {
      package = pkgs.lixPackageSets.git.lix;

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
        # {
        #   hostName = "matara";
        #   system = "x86_64-linux";
        #   protocol = "ssh-ng";
        #   maxJobs = 4;
        #   speedFactor = 2;
        #   supportedFeatures = [
        #     "big-parallel"
        #     "kvm"
        #   ];
        #   mandatoryFeatures = [ ];
        # }
      ];
      distributedBuilds = true;

      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      settings = lib.mkMerge [
        {
          accept-flake-config = true;
          allowed-users = [ "msfjarvis" ];
          auto-optimise-store = true;
          builders-use-substitutes = true;
          experimental-features = lib.mkForce [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
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
        }
      ];
    };
}
