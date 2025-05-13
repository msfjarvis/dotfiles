{
  outputs =
    inputs:
    let
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
        allowAliases = false;
        cudaSupport = true;
        permittedInsecurePackages = [ ];
      };
      homes.modules = with inputs; [
        # niri.homeModules.niri
        nix-flatpak.homeManagerModules.nix-flatpak
        nix-index-database.hmModules.nix-index
        spicetify-nix.homeManagerModules.default
        stylix.homeManagerModules.stylix
      ];
      systems.modules.darwin = with inputs; [
        srvos.darwinModules.desktop
        stylix.darwinModules.stylix
        { stylix.homeManagerIntegration.autoImport = false; }
      ];
      systems.modules.nixos = with inputs; [
        disko.nixosModules.disko
        golink.nixosModules.default
        nix-flatpak.nixosModules.nix-flatpak
        nix-topology.nixosModules.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        { stylix.homeManagerIntegration.autoImport = false; }
        srvos.nixosModules.common
        srvos.nixosModules.mixins-systemd-boot
      ];

      systems.hosts.matara.modules = with inputs; [
        srvos.nixosModules.mixins-mdns
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];
      systems.hosts.melody.modules = with inputs; [
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];
      systems.hosts.ryzenbox.modules = with inputs; [ srvos.nixosModules.desktop ];
      systems.hosts.wailord.modules = with inputs; [
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];

      overlays = with inputs; [
        devshell.overlays.default
        fenix.overlays.default
        # niri.overlays.niri
        nix-topology.overlays.default
      ];
      outputs-builder = channels: {
        topology = import inputs.nix-topology {
          pkgs = channels.nixpkgs;
          modules = [
            { inherit (inputs.self) nixosConfigurations; }
            ./topology.nix
          ];
        };

        formatter =
          let
            treefmtEval = inputs.treefmt-nix.lib.evalModule channels.nixpkgs ./treefmt.nix;
          in
          treefmtEval.config.build.wrapper;
      };

      templates.cpp.description = "devshell for a C++ project";
      templates.go.description = "devshell for a Golang project";
      templates.node.description = "devshell for a NodeJS project";
      templates.python.description = "devshell for a Python project";
      templates.rust.description = "package definition and devshell for my-rust-package";
    };

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    systems.url = "github:msfjarvis/flake-systems";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "git+https://git.lix.systems/lix-project/flake-compat";
    flake-compat.flake = false;

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus?rev=3542fe9126dc492e53ddd252bb0260fe035f2c0f";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";
    firefox.inputs.flake-compat.follows = "flake-compat";
    firefox.inputs.lib-aggregate.follows = "lib-aggregate";

    golink.url = "github:tailscale/golink";
    golink.inputs.nixpkgs.follows = "nixpkgs";
    golink.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lib-aggregate.url = "github:nix-community/lib-aggregate";
    lib-aggregate.inputs.nixpkgs-lib.follows = "nixpkgs";
    lib-aggregate.inputs.flake-utils.follows = "flake-utils";

    lix.url = "git+https://git.lix.systems/lix-project/lix?ref=refs/heads/main";
    lix.inputs.nixpkgs.follows = "nixpkgs";
    lix.inputs.nixpkgs-regression.follows = "nixpkgs";
    lix.inputs.nix2container.follows = "";
    lix.inputs.pre-commit-hooks.follows = "";
    lix.inputs.flake-compat.follows = "flake-compat";

    micro-theme.url = "git+https://github.com/catppuccin/micro";
    micro-theme.flake = false;

    # niri.url = "github:sodiboo/niri-flake";
    # niri.inputs.nixpkgs.follows = "nixpkgs";
    # niri.inputs.nixpkgs-stable.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.inputs.devshell.follows = "devshell";
    nix-topology.inputs.flake-utils.follows = "flake-utils";
    nix-topology.inputs.pre-commit-hooks.follows = "";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    rust-manifest.url = "https://static.rust-lang.org/dist/2025-03-04/channel-rust-nightly.toml";
    rust-manifest.flake = false;

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.flake-compat.follows = "flake-compat";
    snowfall-lib.inputs.flake-utils-plus.follows = "flake-utils-plus";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.systems.follows = "systems";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.flake-compat.follows = "flake-compat";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nur.follows = "";
    stylix.inputs.flake-utils.follows = "flake-utils";
    stylix.inputs.systems.follows = "systems";
    stylix.inputs.git-hooks.follows = "";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    wallpaper.url = "https://til.msfjarvis.dev/20250126195618_1.jpg";
    wallpaper.flake = false;
  };
}
