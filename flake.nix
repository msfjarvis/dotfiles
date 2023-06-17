{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    custom-nixpkgs = {
      url = "github:msfjarvis/custom-nixpkgs/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    custom-nixpkgs,
    home-manager,
    darwin,
    nix-index-database,
    ...
  }: let
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        custom = import custom-nixpkgs {inherit pkgs;};
      };
    };
    pkgs = import nixpkgs {
      inherit config;
      system = "x86_64-linux";
    };
    fileList = [
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
    files = pkgs.lib.concatStringsSep " " fileList;
    formatter = pkgs.stdenvNoCC.mkDerivation {
      name = "formatter";
      doCheck = false;
      strictDeps = true;
      allowSubstitutes = false;
      src = builtins.filterSource (p: t: builtins.elem (/. + p) fileList) ./.;
      nativeBuildInputs = with pkgs; [alejandra shfmt];
      buildPhase = ''
        mkdir -p $out/bin
        echo "shfmt -w -s -i 2 -ci ${files}" > $out/bin/$name
        echo "alejandra --quiet ." >> $out/bin/$name
        chmod +x $out/bin/$name
      '';
    };
    ryzenboxSystem = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit config;
        system = "x86_64-linux";
      };
      modules = [
        nix-index-database.hmModules.nix-index
        ./nixos/ryzenbox-configuration.nix
      ];
    };
    serverSystem = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit config;
        system = "aarch64-linux";
      };
      modules = [
        nix-index-database.hmModules.nix-index
        ./nixos/server-configuration.nix
      ];
    };
    darwinSystem = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit config;
        system = "aarch64-darwin";
      };
      modules = [
        home-manager.darwinModules.home-manager
        ./nixos/darwin-configuration.nix
      ];
    };
  in {
    formatter.x86_64-linux = formatter;
    homeConfigurations.ryzenbox = ryzenboxSystem;
    homeConfigurations.server = serverSystem;
    darwinConfigurations.work-macbook = darwinSystem;
    packages.x86_64-linux.ryzenbox = ryzenboxSystem.activationPackage;
    packages.aarch64-linux.server = serverSystem.activationPackage;
    packages.aarch64-darwin.macbook = darwinSystem.system;
    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        alejandra
        bash
        delta
        git
        micro
        nil
        shellcheck
        shfmt
      ];
    };
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
