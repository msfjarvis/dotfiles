{
  description = "msfjarvis' NixOS configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # inputs.nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";
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

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

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

  inputs.srvos.url = "github:nix-community/srvos";
  inputs.srvos.inputs.nixpkgs.follows = "nixpkgs";

  inputs.stylix.url = "github:danth/stylix";
  inputs.stylix.inputs.flake-compat.follows = "";
  inputs.stylix.inputs.home-manager.follows = "home-manager";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";

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
    apps = forAllSystems (system: {inherit (deploy-rs.apps.${system}) default;});

    formatter = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      pkgs.writeShellApplication {
        name = "format";
        runtimeInputs = with pkgs; [
          alejandra
          deadnix
          shfmt
          statix
        ];
        text = ''
          set -euo pipefail
          shfmt --write --simplify --language-dialect bash --indent 2 --case-indent --space-redirects .;
          deadnix --edit
          statix check . || statix fix .
          alejandra --quiet .
        '';
      });

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
              inputs.stylix.nixosModules.stylix
              inputs.srvos.nixosModules.common
              inputs.srvos.nixosModules.mixins-systemd-boot
              ({lib, ...}: {
                stylix.autoEnable = lib.mkDefault false;
                stylix.image = lib.mkDefault ./nixos/stylix-fakes/wall.png;
                stylix.base16Scheme = lib.mkDefault ./nixos/stylix-fakes/dracula.yml;
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
              })
              (import (./machines + "/${name}"))
              {nixpkgs.pkgs = pkgs;}
            ]
            ++ (
              if name == "wailord"
              then [inputs.disko.nixosModules.disko inputs.srvos.nixosModules.server]
              else []
            )
            ++ (
              if name == "crusty"
              then [inputs.nixos-hardware.nixosModules.raspberry-pi-4 inputs.srvos.nixosModules.server]
              else []
            )
            ++ (
              if name == "ryzenbox"
              then [inputs.srvos.nixosModules.desktop]
              else []
            );
          specialArgs = {inherit inputs;};
        };
    in
      genAttrs hosts mkHost;
    packages.x86_64-linux.crusty = self.nixosConfigurations.crusty.config.system.build.sdImage;
    deploy = {
      user = "root";
      nodes =
        builtins.mapAttrs (_: machine: {
          hostname = machine.config.networking.hostName;
          fastConnection = true;
          remoteBuild = true;
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.${machine.pkgs.system}.activate.nixos machine;
          };
        })
        self.nixosConfigurations;
    };

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
