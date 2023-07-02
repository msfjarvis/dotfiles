{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.custom-nixpkgs.url = "github:msfjarvis/custom-nixpkgs/main";
  inputs.custom-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.custom-nixpkgs.inputs.systems.follows = "systems";
  inputs.custom-nixpkgs.inputs.fenix.follows = "fenix";

  inputs.darwin.url = "github:LnL7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell.inputs.systems.follows = "systems";

  inputs.dracula-micro.url = "https://raw.githubusercontent.com/dracula/micro/master/dracula.micro";
  inputs.dracula-micro.flake = false;

  inputs.fenix.url = "github:nix-community/fenix";
  inputs.fenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:nix-community/flake-compat";
  inputs.flake-compat.flake = false;

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-filter.url = "github:numtide/nix-filter";

  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.devshell-cpp.url = "path:./nixos/shell-configs/cpp";
  inputs.devshell-cpp.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell-cpp.inputs.systems.follows = "systems";
  inputs.devshell-cpp.inputs.devshell.follows = "devshell";
  inputs.devshell-cpp.inputs.flake-compat.follows = "flake-compat";
  inputs.devshell-cpp.inputs.flake-utils.follows = "flake-utils";

  inputs.devshell-go.url = "path:./nixos/shell-configs/go";
  inputs.devshell-go.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell-go.inputs.systems.follows = "systems";
  inputs.devshell-go.inputs.devshell.follows = "devshell";
  inputs.devshell-go.inputs.flake-compat.follows = "flake-compat";
  inputs.devshell-go.inputs.flake-utils.follows = "flake-utils";

  inputs.devshell-node.url = "path:./nixos/shell-configs/node";
  inputs.devshell-node.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell-node.inputs.systems.follows = "systems";
  inputs.devshell-node.inputs.devshell.follows = "devshell";
  inputs.devshell-node.inputs.flake-compat.follows = "flake-compat";
  inputs.devshell-node.inputs.flake-utils.follows = "flake-utils";

  inputs.devshell-python.url = "path:./nixos/shell-configs/python";
  inputs.devshell-python.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell-python.inputs.systems.follows = "systems";
  inputs.devshell-python.inputs.devshell.follows = "devshell";
  inputs.devshell-python.inputs.flake-compat.follows = "flake-compat";
  inputs.devshell-python.inputs.flake-utils.follows = "flake-utils";

  inputs.devshell-rust.url = "path:./nixos/shell-configs/rust";
  inputs.devshell-rust.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell-rust.inputs.systems.follows = "systems";
  inputs.devshell-rust.inputs.devshell.follows = "devshell";
  inputs.devshell-rust.inputs.fenix.follows = "fenix";
  inputs.devshell-rust.inputs.flake-compat.follows = "flake-compat";
  inputs.devshell-rust.inputs.flake-utils.follows = "flake-utils";

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
    mkHomeManagerConfig = options:
      home-manager.lib.homeManagerConfiguration {
        pkgs = packagesFn options.system;
        modules =
          options.modules
          ++ [
            inputs.nix-index-database.hmModules.nix-index
            ./nixos/home-manager-common.nix
            ({...}: {
              home.file.".config/micro/colorschemes/dracula.micro".source = inputs.dracula-micro;
            })
          ];
      };
  in rec {
    homeConfigurations.ryzenbox = mkHomeManagerConfig {
      system = "x86_64-linux";
      modules = [./nixos/ryzenbox-configuration.nix];
    };
    homeConfigurations.server = mkHomeManagerConfig {
      system = "aarch64-linux";
      modules = [./nixos/server-configuration.nix];
    };
    darwinConfigurations.work-macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = packagesFn "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./nixos/darwin-configuration.nix
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
    devShells = eachSystem (system: {
      cpp = inputs.devshell-cpp.devShells.${system}.default;
      go = inputs.devshell-go.devShells.${system}.default;
      node = inputs.devshell-node.devShells.${system}.default;
      python = inputs.devshell-python.devShells.${system}.default;
      rust = inputs.devshell-rust.devShells.${system}.default;
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
