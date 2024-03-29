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
      ];
      systems.modules.nixos = with inputs; [
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
        nix-vscode-extensions.overlays.default
      ];
      outputs-builder = channels: {
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
    }
    // {
      apps.x86_64-linux.default = inputs.deploy-rs.apps.x86_64-linux.default;
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
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    systems.url = "github:msfjarvis/flake-systems";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.flake-compat.follows = "";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
    dracula-micro.flake = false;

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    gphotos-cdp.url = "github:msfjarvis/gphotos-cdp";
    gphotos-cdp.inputs.flake-compat.follows = "";
    gphotos-cdp.inputs.flake-utils.follows = "flake-utils";
    gphotos-cdp.inputs.nixpkgs.follows = "nixpkgs";
    gphotos-cdp.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
    nix-vscode-extensions.inputs.flake-compat.follows = "";

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

    rust-manifest.url = "https://static.rust-lang.org/dist/2024-01-09/channel-rust-nightly.toml";
    rust-manifest.flake = false;

    snowfall-lib.url = "github:snowfallorg/lib/dev";
    snowfall-lib.inputs.flake-utils-plus.follows = "flake-utils-plus";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.flake-compat.follows = "";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
