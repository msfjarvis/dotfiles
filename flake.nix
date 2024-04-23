{
  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
      snowfall = {
        namespace = "jarvis";
        meta = {
          name = "msfjarvis-nix-configs";
          title = "msfjarvis' Nix configurations";
        };
      };
    };
  in
    lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config = {
        allowUnfree = true;
        cudaSupport = true;
      };
      homes.modules = with inputs; [
        nix-index-database.hmModules.nix-index
        spicetify-nix.homeManagerModules.default
      ];
      systems.modules.nixos = with inputs; [
        nix-topology.nixosModules.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        srvos.nixosModules.common
        srvos.nixosModules.mixins-systemd-boot
      ];

      systems.hosts.crusty.modules = with inputs; [
        nixos-hardware.nixosModules.raspberry-pi-4
        srvos.nixosModules.server
      ];
      systems.hosts.ryzenbox.modules = with inputs; [
        srvos.nixosModules.desktop
      ];
      systems.hosts.wailord.modules = with inputs; [
        disko.nixosModules.disko
        srvos.nixosModules.server
      ];

      overlays = with inputs; [
        fenix.overlays.default
        gphotos-cdp.overlays.default
        nix-topology.overlays.default
        nix-vscode-extensions.overlays.default
      ];
      outputs-builder = channels: {
        topology = import inputs.nix-topology {
          pkgs = channels.nixpkgs;
          modules = [
            {inherit (inputs.self) nixosConfigurations;}
            ./topology.nix
          ];
        };

        formatter = channels.nixpkgs.writeShellApplication {
          name = "format";
          runtimeInputs = with channels.nixpkgs; [
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
        };
      };

      deploy = lib.mkDeploy {inherit (inputs) self;};
      apps.x86_64-linux.default = inputs.deploy-rs.apps.x86_64-linux.default;

      templates.cpp = {
        description = "devshell for a C++ project";
        path = ./templates/cpp;
      };
      templates.go = {
        description = "devshell for a Golang project";
        path = ./templates/go;
      };
      templates.node = {
        description = "devshell for a NodeJS project";
        path = ./templates/node;
      };
      templates.python = {
        description = "devshell for a Python project";
        path = ./templates/python;
      };
      templates.rust = {
        description = "package definition and devshell for my-rust-package";
        path = ./templates/rust;
      };
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

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    systems.url = "github:msfjarvis/flake-systems";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.flake-compat.follows = "flake-compat";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
    dracula-micro.flake = false;

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:nix-community/flake-compat";
    flake-compat.flake = false;

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";
    firefox.inputs.cachix.follows = "nixpkgs";
    firefox.inputs.flake-compat.follows = "flake-compat";

    gphotos-cdp.url = "github:msfjarvis/gphotos-cdp";
    gphotos-cdp.inputs.devshell.follows = "devshell";
    gphotos-cdp.inputs.flake-compat.follows = "flake-compat";
    gphotos-cdp.inputs.flake-utils.follows = "flake-utils";
    gphotos-cdp.inputs.nixpkgs.follows = "nixpkgs";
    gphotos-cdp.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.inputs.devshell.follows = "devshell";
    nix-topology.inputs.flake-utils.follows = "flake-utils";
    nix-topology.inputs.pre-commit-hooks.follows = "";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
    nix-vscode-extensions.inputs.flake-compat.follows = "flake-compat";

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

    rust-manifest.url = "https://static.rust-lang.org/dist/2024-01-09/channel-rust-nightly.toml";
    rust-manifest.flake = false;

    snowfall-lib.url = "github:snowfallorg/lib/dev";
    snowfall-lib.inputs.flake-compat.follows = "flake-compat";
    snowfall-lib.inputs.flake-utils-plus.follows = "flake-utils-plus";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.flake-compat.follows = "flake-compat";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.flake-compat.follows = "flake-compat";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    wallpaper.url = "https://til.msfjarvis.dev/wallpaper.jpg";
    wallpaper.flake = false;
    nixpkgs-news = {
      url = "github:jakehamilton/nixpkgs.news";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.snowfall-lib.follows = "snowfall-lib";
      inputs.unstable.follows = "nixpkgs";
    };
  };
}
