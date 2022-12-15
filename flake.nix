{
  description = "Home Manager configurations of Harsh Shandilya";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-nixpkgs = {
      url = "github:msfjarvis/custom-nixpkgs/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, custom-nixpkgs, ... }:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        packageOverrides = pkgs: {
          custom = import custom-nixpkgs { inherit pkgs; };
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        inherit config;
      };
    in {
      homeConfigurations.ryzenbox = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          inherit config;
        };
        modules = [ ./nixos/ryzenbox-configuration.nix ];
      };
      homeConfigurations.server = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          inherit config;
        };
        modules = [ ./nixos/server-configuration.nix ];
      };
      devShells.${system}.default = pkgs.mkShell {
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
    };
}
