{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.agenix.inputs.darwin.follows = "darwin";
  inputs.agenix.inputs.home-manager.follows = "home-manager";

  inputs.cachix-deploy.url = "github:cachix/cachix-deploy-flake/main";
  inputs.cachix-deploy.inputs.nixpkgs.follows = "nixpkgs";
  inputs.cachix-deploy.inputs.darwin.follows = "darwin";
  inputs.cachix-deploy.inputs.home-manager.follows = "home-manager";

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
    self,
    nixpkgs,
    home-manager,
    darwin,
    systems,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
    packagesFn = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [inputs.custom-nixpkgs.overlays.default inputs.nixgl.overlays.default];
      };
    pkgs = forAllSystems (system: packagesFn system);

    mkHomeManagerConfig = options:
      home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit (inputs) dracula-micro;
        };
        pkgs = pkgs.${options.system};
        modules =
          options.modules
          ++ [
            inputs.nix-index-database.hmModules.nix-index
            ./nixos/modules/home-manager-common.nix
            ./nixos/modules/micro.nix
          ];
      };
    cachix-deploy-lib = inputs.cachix-deploy.lib (packagesFn "aarch64-linux");
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
      pkgs = pkgs."aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./nixos/hosts/work-macbook/configuration.nix
      ];
    };
    nixosConfigurations.crusty = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        inputs.agenix.nixosModules.default
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        inputs.nix-index-database.nixosModules.nix-index
        inputs.nixos-vscode-server.nixosModules.default
        home-manager.nixosModules.home-manager
        ./nixos/hosts/crusty/configuration.nix
        ({config, ...}: {
          age.secrets."crusty-cachix-deploy".file = ./secrets/crusty-cachix-deploy.age;
          environment.etc."cachix-agent.token".source = config.age.secrets."crusty-cachix-deploy".path;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.msfjarvis = import ./nixos/hosts/crusty/home-manager.nix;
          programs.nix-index-database.comma.enable = true;
          services.vscode-server.enable = true;
        })
      ];
    };
    packages.aarch64-linux = {
      cachix-deploy-spec = cachix-deploy-lib.spec {
        agents.crusty = self.nixosConfigurations.crusty.config.system.build.toplevel;
      };
    };

    packages.x86_64-linux.ryzenbox = homeConfigurations.ryzenbox.activationPackage;
    packages.aarch64-linux.server = homeConfigurations.server.activationPackage;
    packages.aarch64-darwin.macbook = darwinConfigurations.work-macbook.system;

    apps = forAllSystems (system: {
      format = {
        type = "app";
        program = let
          fmtTargetsStr = pkgs.${system}.lib.concatStringsSep " " [
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

          script = pkgs.${system}.writeShellApplication {
            name = "format";
            runtimeInputs = with pkgs.${system}; [
              alejandra
              shfmt
            ];
            text = ''
              shfmt -w -s -i 2 -ci ${fmtTargetsStr};
              alejandra --quiet .
            '';
          };
        in "${script}/bin/format";
      };
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
