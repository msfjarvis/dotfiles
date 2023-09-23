{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.agenix.inputs.darwin.follows = "darwin";
  inputs.agenix.inputs.home-manager.follows = "home-manager";

  inputs.custom-nixpkgs.url = "github:msfjarvis/custom-nixpkgs/main";
  inputs.custom-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.custom-nixpkgs.inputs.systems.follows = "systems";

  inputs.darwin.url = "github:LnL7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
  inputs.dracula-micro.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixgl.url = "github:guibou/nixGL";
  inputs.nixgl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixgl.inputs.flake-utils.follows = "flake-utils";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-vscode-extensions.inputs.flake-compat.follows = "";

  inputs.nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

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
        overlays = [
          inputs.custom-nixpkgs.overlays.default
          inputs.nixgl.overlays.default
          inputs.nix-vscode-extensions.overlays.default
          (import ./nixos/overlays)
        ];
      };
    pkgs = forAllSystems packagesFn;

    mkHomeManagerConfig = options: let
      nixGLWrap = (import ./nixos/modules/nixGL) pkgs.${options.system};
    in
      home-manager.lib.homeManagerConfiguration {
        inherit (options) modules;
        extraSpecialArgs = {
          inherit (inputs) dracula-micro;
          inherit nixGLWrap;
        };
        pkgs = pkgs.${options.system};
      };
    hmModules = [
      ./nixos/modules/home-manager
      ./nixos/modules/micro
      ./nixos/modules/password-store
      ./nixos/modules/vscode
      inputs.nix-index-database.hmModules.nix-index
    ];
    serverHmModules = [
      ./nixos/modules/home-manager
      ./nixos/modules/micro
      inputs.nix-index-database.hmModules.nix-index
    ];
    nixosModules = [
      home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.nixos-vscode-server.nixosModules.default
      ./nixos/modules/nix
      (_: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit (inputs) dracula-micro;};
      })
    ];
  in rec {
    homeConfigurations.ryzenbox = mkHomeManagerConfig {
      system = "x86_64-linux";
      modules = [./nixos/hosts/ryzenbox] ++ hmModules;
    };
    darwinConfigurations.work-macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = pkgs."aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./nixos/hosts/work-macbook
        ({lib, ...}: {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = {inherit (inputs) dracula-micro;};
          home-manager.users.msfjarvis = lib.mkMerge [
            {imports = hmModules;}
            (import ./nixos/hosts/work-macbook/home-manager.nix)
          ];
        })
      ];
    };
    nixosConfigurations.crusty = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules =
        nixosModules
        ++ [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          ./nixos/modules/rucksack
          ./nixos/hosts/crusty
          ({
            config,
            lib,
            ...
          }: {
            age.secrets."crusty-transmission-settings".file = ./secrets/crusty-transmission-settings.age;
            environment.etc."extra-transmission-settings".source = config.age.secrets."crusty-transmission-settings".path;
            home-manager.users.msfjarvis = lib.mkMerge [
              {imports = serverHmModules;}
              (import ./nixos/hosts/crusty/home-manager.nix)
            ];
            nixpkgs.overlays = [inputs.custom-nixpkgs.overlays.default];
            services.vscode-server.enable = true;
          })
        ];
    };
    nixosConfigurations.wailord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        nixosModules
        ++ [
          ./nixos/hosts/wailord
          ({
            config,
            lib,
            ...
          }: {
            home-manager.users.msfjarvis = lib.mkMerge [
              {imports = serverHmModules;}
              (import ./nixos/hosts/wailord/home-manager.nix)
            ];
            nixpkgs.overlays = [inputs.custom-nixpkgs.overlays.default];
          })
        ];
    };

    packages.x86_64-linux.wailord = nixosConfigurations.wailord.config.system.build.toplevel;
    packages.x86_64-linux.ryzenbox = homeConfigurations.ryzenbox.activationPackage;
    packages.aarch64-linux.crusty = nixosConfigurations.crusty.config.system.build.toplevel;
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
              statix
            ];
            text = ''
              shfmt -w -s -i 2 -ci ${fmtTargetsStr};
              alejandra --quiet .
              statix check .
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
