{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-nixpkgs = {
      url = "github:msfjarvis/custom-nixpkgs/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, custom-nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        files = pkgs.lib.concatStringsSep " " [
          "aliases"
          "apps"
          "bash_completions.bash"
          "common"
          "devtools"
          "files"
          "gitshit"
          "install.sh"
          "minecraft"
          "nix"
          "nixos/setup-channels.sh"
          "paste"
          "pre-push-hook"
          "server"
          "setup/00-android_sdk.sh"
          "setup/01-adb_multi.sh"
          "setup/02-android_udev.sh"
          "setup/common.sh"
          "shell-init"
          "system"
          "system_linux"
          "x"
        ];
        config = {
          allowUnfree = true;
          packageOverrides = pkgs: {
            custom = import custom-nixpkgs { inherit pkgs; };
          };
        };
        pkgs = import nixpkgs { inherit system config; };
        pkgsX86 = import nixpkgs {
          system = "x86_64-linux";
          inherit config;
        };
        pkgsAarch64 = import nixpkgs {
          system = "aarch64-linux";
          inherit config;
        };
        fmt = pkgs.stdenvNoCC.mkDerivation {
          name = "fmt";
          doCheck = true;
          dontBuild = true;
          strictDeps = true;
          src = ./.;
          nativeBuildInputs = with pkgs; [ fd alejandra shellcheck shfmt ];
          checkPhase = ''
            shfmt -d -s -i 2 -ci ${files}
            fd -tf \\.nix$ -X alejandra -c
            shellcheck -x ${files}
          '';
          installPhase = ''
            runHook preInstall
            mkdir "$out"
            runHook postInstall
          '';
        };
      in {
        checks = { inherit fmt; };
        homeConfigurations.ryzenbox =
          home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsX86;
            modules = [ ./nixos/ryzenbox-configuration.nix ];
          };
        homeConfigurations.server = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsAarch64;
          modules = [ ./nixos/server-configuration.nix ];
        };
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            alejandra
            bash
            delta
            git
            micro
            rnix-lsp
            shellcheck
            shfmt
          ];
        };
      });
}
