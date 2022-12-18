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

  outputs = {
    nixpkgs,
    home-manager,
    custom-nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (system: let
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
          custom = import custom-nixpkgs {inherit pkgs;};
        };
      };
      pkgs = import nixpkgs {inherit system config;};
      fmt-check = pkgs.stdenvNoCC.mkDerivation {
        name = "fmt-check";
        doCheck = true;
        dontBuild = true;
        strictDeps = true;
        src = ./.;
        nativeBuildInputs = with pkgs; [alejandra shellcheck shfmt];
        checkPhase = ''
          shfmt -d -s -i 2 -ci ${files}
          alejandra -c .
          shellcheck -x ${files}
        '';
        installPhase = ''
          runHook preInstall
          mkdir "$out"
          runHook postInstall
        '';
      };
      formatter = pkgs.stdenvNoCC.mkDerivation {
        name = "formatter";
        doCheck = false;
        strictDeps = true;
        src = ./.;
        nativeBuildInputs = with pkgs; [alejandra shfmt];
        buildPhase = ''
          mkdir -p $out/bin
          echo "shfmt -w -s -i 2 -ci ${files}" > $out/bin/$name
          echo "alejandra ." >> $out/bin/$name
          chmod +x $out/bin/$name
        '';
      };
    in {
      checks = {inherit fmt-check;};
      formatter = formatter;
      homeConfigurations.ryzenbox = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./nixos/ryzenbox-configuration.nix];
      };
      homeConfigurations.server = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./nixos/server-configuration.nix];
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
