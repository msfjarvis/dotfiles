{
  outputs =
    inputs:
    import ./lib/flake.nix {
      inherit inputs;
      namespace = "jarvis";
      nixpkgsConfig = {
        allowUnfree = true;
        allowAliases = false;
        cudaSupport = false;
        permittedInsecurePackages = [ ];
      };
      homes.modules = with inputs; [
        # niri.homeModules.niri
        nix-flatpak.homeManagerModules.nix-flatpak
        nix-index-database.homeModules.nix-index
        spicetify-nix.homeManagerModules.default
      ];
      systems.modules.darwin = with inputs; [
        srvos.darwinModules.desktop
        stylix.darwinModules.stylix
      ];
      systems.modules.nixos = with inputs; [
        copyparty.nixosModules.default
        disko.nixosModules.disko
        golink.nixosModules.default
        nix-flatpak.nixosModules.nix-flatpak
        nix-topology.nixosModules.default
        rex.nixosModules.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
      ];

      systems.hosts.matara.modules = with inputs; [
        srvos.nixosModules.common
        srvos.nixosModules.mixins-mdns
        srvos.nixosModules.mixins-systemd-boot
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];
      systems.hosts.melody.modules = with inputs; [
        nix-index-database.nixosModules.default
        srvos.nixosModules.common
        srvos.nixosModules.mixins-systemd-boot
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];
      systems.hosts.ryzenbox.modules = with inputs; [
        srvos.nixosModules.common
        srvos.nixosModules.mixins-systemd-boot
        srvos.nixosModules.desktop
      ];
      systems.hosts.stash.modules = with inputs; [ microvm.nixosModules.microvm ];
      systems.hosts.wailord.modules = with inputs; [
        srvos.nixosModules.common
        srvos.nixosModules.mixins-systemd-boot
        srvos.nixosModules.mixins-telegraf
        srvos.nixosModules.roles-prometheus
        srvos.nixosModules.server
      ];

      overlays = with inputs; [
        copyparty.overlays.default
        devshell.overlays.default
        fenix.overlays.default
        microvm.overlays.default
        # niri.overlays.niri
        nix-topology.overlays.default
      ];
      perSystem = pkgs: {
        topology = import inputs.nix-topology {
          inherit pkgs;
          modules = [
            { inherit (inputs.self) nixosConfigurations; }
            ./topology.nix
          ];
        };

        formatter =
          let
            treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
    # Automatically built and uploaded by rebase.yml in msfjarvis/nixpkgs
    nixpkgs.url = "https://nix-channels.msfjarvis.dev/nixpkgs/latest.tar.zst";

    systems.url = "github:msfjarvis/flake-systems";

    copyparty.url = "github:9001/copyparty";
    copyparty.inputs.nixpkgs.follows = "nixpkgs";
    copyparty.inputs.flake-utils.follows = "flake-utils";

    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "git+https://git.lix.systems/lix-project/flake-compat";
    flake-compat.flake = false;

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "lib-aggregate";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

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

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.inputs.systems.follows = "systems";
    llm-agents.inputs.treefmt-nix.follows = "treefmt-nix";
    llm-agents.inputs.flake-parts.follows = "flake-parts";

    micro-theme.url = "git+https://github.com/catppuccin/micro";
    micro-theme.flake = false;

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    # niri.url = "github:sodiboo/niri-flake";
    # niri.inputs.nixpkgs.follows = "nixpkgs";
    # niri.inputs.nixpkgs-stable.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.inputs.flake-parts.follows = "flake-parts";

    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
    rex.inputs.nixpkgs.follows = "nixpkgs";

    rust-manifest.url = "https://static.rust-lang.org/dist/2025-03-04/channel-rust-nightly.toml";
    rust-manifest.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.systems.follows = "systems";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nur.follows = "";
    stylix.inputs.systems.follows = "systems";
    stylix.inputs.flake-parts.follows = "flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
