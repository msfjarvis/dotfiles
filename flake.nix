{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.custom-nixpkgs.url = "github:msfjarvis/custom-nixpkgs/main";
  inputs.custom-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.custom-nixpkgs.inputs.systems.follows = "systems";

  inputs.darwin.url = "github:LnL7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-filter.url = "github:numtide/nix-filter";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    systems,
    ...
  } @ inputs: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
    packagesFn = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [inputs.custom-nixpkgs.overlays.default];
      };
    fmtTargets = [
      "aliases"
      "apps"
      "bash_completions.bash"
      "common"
      "darwin-init"
      "devtools"
      "files"
      "gitshit"
      "install.sh"
      "minecraft"
      "nix"
      "nixos/setup-channels.sh"
      "pre-push-hook"
      "setup/00-android_sdk.sh"
      "setup/01-adb_multi.sh"
      "setup/02-android_udev.sh"
      "shell-init"
      "system"
      "system_darwin"
      "system_linux"
      "x"
    ];
    ryzenboxSystem = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = packagesFn system;
        modules = [
          inputs.nix-index-database.hmModules.nix-index
          ./nixos/ryzenbox-configuration.nix
        ];
      };
    serverSystem = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = packagesFn system;
        modules = [
          inputs.nix-index-database.hmModules.nix-index
          ./nixos/server-configuration.nix
        ];
      };
    darwinSystem = system:
      darwin.lib.darwinSystem {
        inherit system;
        pkgs = packagesFn system;
        modules = [
          home-manager.darwinModules.home-manager
          ./nixos/darwin-configuration.nix
        ];
      };
  in rec {
    homeConfigurations.ryzenbox = ryzenboxSystem "x86_64-linux";
    homeConfigurations.server = serverSystem "aarch64-linux";
    darwinConfigurations.work-macbook = darwinSystem "aarch64-darwin";

    packages.x86_64-linux.ryzenbox = homeConfigurations.ryzenbox.activationPackage;
    packages.aarch64-linux.server = homeConfigurations.server.activationPackage;
    packages.aarch64-darwin.macbook = darwinConfigurations.work-macbook.system;

    formatter = eachSystem (system: let
      pkgs = packagesFn system;
      fmtTargetsStr = pkgs.lib.concatStringsSep " " fmtTargets;
    in
      pkgs.stdenvNoCC.mkDerivation {
        name = "formatter";
        doCheck = false;
        strictDeps = true;
        allowSubstitutes = false;
        src = inputs.nix-filter.lib {
          root = ./.;
          include = fmtTargets;
        };
        nativeBuildInputs = with pkgs; [alejandra shfmt];
        buildPhase = ''
          mkdir -p $out/bin
          echo "shfmt -w -s -i 2 -ci ${fmtTargetsStr}" > $out/bin/$name
          echo "alejandra --quiet ." >> $out/bin/$name
          chmod +x $out/bin/$name
        '';
      });
  };
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
