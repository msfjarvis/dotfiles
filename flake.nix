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

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.deploy-rs.inputs.flake-compat.follows = "";
  inputs.deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.deploy-rs.inputs.utils.follows = "flake-utils";

  inputs.dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
  inputs.dracula-micro.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-vscode-extensions.inputs.flake-compat.follows = "";

  inputs.nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "";

  outputs = {
    nixpkgs,
    self,
    deploy-rs,
    ...
  } @ inputs: let
    findModules = dir:
      builtins.concatLists (builtins.attrValues (builtins.mapAttrs
        (name: type:
          if type == "regular"
          then [
            {
              name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
              value = dir + "/${name}";
            }
          ]
          else if
            (builtins.readDir (dir + "/${name}"))
            ? "default.nix"
          then [
            {
              inherit name;
              value = dir + "/${name}";
            }
          ]
          else findModules (dir + "/${name}")) (builtins.readDir dir)));
    pkgsFor = system:
      import inputs.nixpkgs {
        config = {
          allowUnfree = true;
        };
        overlays = [
          self.overlay
          inputs.custom-nixpkgs.overlays.default
          inputs.nix-vscode-extensions.overlays.default
        ];
        localSystem = {inherit system;};
      };
    forAllSystems = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
  in {
    inherit (deploy-rs) defaultApp;
    overlay = import ./overlays;
    nixosModules = builtins.listToAttrs (findModules ./modules);
    nixosConfigurations = with nixpkgs.lib; let
      hosts = builtins.attrNames (builtins.readDir ./machines);
      mkHost = name: let
        system = builtins.readFile (./machines + "/${name}/system");
        pkgs = pkgsFor system;
      in
        nixosSystem {
          inherit system;
          modules =
            __attrValues self.nixosModules
            ++ [
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
              {
                sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
                sops.defaultSopsFile = ./secrets/tailscale.yaml;
                sops.secrets.tsauthkey = {};
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {inherit (inputs) dracula-micro;};
                  users.msfjarvis = {
                    imports =
                      (import ./home-manager)
                      ++ [
                        inputs.nix-index-database.hmModules.nix-index
                      ];
                  };
                };
              }
              (import (./machines + "/${name}"))
              {nixpkgs.pkgs = pkgs;}
            ];
          specialArgs = {inherit inputs;};
        };
    in
      genAttrs hosts mkHost;
    deploy = {
      user = "root";
      nodes =
        builtins.mapAttrs (machine: {
          hostname = machine.config.networking.hostName;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${machine.pkgs.system}.activate.nixos machine;
          };
        })
        self.nixosConfigurations;
    };
    apps = forAllSystems (system: {
      format = {
        type = "app";
        program = let
          pkgs = pkgsFor system;
          inherit (pkgs) lib;
          getDirFiles = dir:
            builtins.map (x: "${dir}/" + x) (builtins.attrNames (builtins.readDir dir));
          fmtTargetsStr = lib.concatStringsSep " " ([
              "darwin-init"
              "shell-init"
              "x"
            ]
            ++ getDirFiles ./scripts);

          script = pkgs.writeShellApplication {
            name = "format";
            runtimeInputs = with pkgs; [
              alejandra
              deadnix
              shfmt
              statix
            ];
            text = ''
              set -euo pipefail
              shfmt -w -s -i 2 -ci ${fmtTargetsStr};
              alejandra --quiet .
              deadnix --edit
              statix check .
            '';
          };
        in "${script}/bin/format";
      };
    });

    darwinConfigurations.Harshs-MacBook-Pro = inputs.darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      pkgs = pkgsFor system;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ./darwin
        ({lib, ...}: {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = {inherit (inputs) dracula-micro;};
          home-manager.users.msfjarvis = lib.mkMerge [
            {
              imports =
                (import ./home-manager)
                ++ [
                  inputs.nix-index-database.hmModules.nix-index
                ];
            }
            (import ./darwin/home-manager.nix)
          ];
        })
      ];
    };
    packages.aarch64-darwin.macbook = self.darwinConfigurations.Harshs-MacBook-Pro.system;
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
