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
      in {
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
            bash
            delta
            git
            micro
            nixfmt
            rnix-lsp
            shellcheck
            shfmt
          ];
        };
      });
}
