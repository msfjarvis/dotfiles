{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.custom-nixpkgs.url = "github:msfjarvis/custom-nixpkgs/main";
  inputs.custom-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.custom-nixpkgs.inputs.systems.follows = "systems";

  inputs.darwin.url = "github:LnL7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
  inputs.dracula-micro.flake = false;

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-filter.url = "github:numtide/nix-filter";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixgl.url = "github:guibou/nixGL";
  inputs.nixgl.inputs.nixpkgs.follows = "nixpkgs";

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
        overlays = [inputs.custom-nixpkgs.overlays.default inputs.nixgl.overlays.default];
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
    mkHomeManagerConfig = options:
      home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit (inputs) dracula-micro;
        };
        pkgs = packagesFn options.system;
        modules =
          options.modules
          ++ [
            inputs.nix-index-database.hmModules.nix-index
            ./nixos/modules/home-manager-common.nix
            ./nixos/modules/micro.nix
          ];
      };
  in rec {
    homeConfigurations.ryzenbox = mkHomeManagerConfig {
      system = "x86_64-linux";
      modules = [./nixos/hosts/ryzenbox/configuration.nix];
    };
    homeConfigurations.server = mkHomeManagerConfig {
      system = "aarch64-linux";
      modules = [./nixos/hosts/boatymcboatface/configuration.nix];
    };
    darwinConfigurations.work-macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = packagesFn "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./nixos/hosts/work-macbook/configuration.nix
      ];
    };
    nixosConfigurations.crusty = nixpkgs.lib.nixosSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.nixos-vscode-server.nixosModules.default
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        inputs.nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        ./nixos/hosts/crusty/configuration.nix
        {
          programs.nix-index-database.comma.enable = true;
          services.vscode-server.enable = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.msfjarvis = import ./nixos/hosts/crusty/home-manager.nix;
        }
      ];
    };

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
      "https://msfjarvis.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "msfjarvis.cachix.org-1:/sKPgZblk/LgoOKtDgMTwvRuethILGkr/maOvZ6W11U="
    ];
  };
}
