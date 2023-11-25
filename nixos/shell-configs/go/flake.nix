{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell.inputs.systems.follows = "systems";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.flake-compat.url = "github:nix-community/flake-compat";
  inputs.flake-compat.flake = false;

  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
  inputs.nix-vscode-extensions.inputs.flake-compat.follows = "flake-compat";

  outputs = {
    nixpkgs,
    devshell,
    flake-utils,
    nix-vscode-extensions,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [devshell.overlays.default nix-vscode-extensions.overlays.default];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        bash = {interactive = "";};

        env = [
          {
            name = "DEVSHELL_NO_MOTD";
            value = 1;
          }
        ];

        packages = with pkgs; [
          git
          go-outline
          go_1_21
          gopls
          gotools
          (vscode-with-extensions.override {
            vscodeExtensions = with pkgs.vscode-marketplace; [
              arrterian.nix-env-selector
              eamodio.gitlens
              golang.go
              jnoortheen.nix-ide
              k--kato.intellij-idea-keybindings
              mtdmali.daybreak-theme
              oderwat.indent-rainbow
            ];
          })
        ];
      };
    });
}
