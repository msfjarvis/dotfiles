{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      rustStable = pkgs.rust-bin.stable.latest.default.override {
        extensions = ["rust-src"];
        targets =
          pkgs.lib.optionals pkgs.stdenv.isDarwin ["aarch64-apple-darwin"]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux
          ["x86_64-unknown-linux-gnu"];
      };
    in {
      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks;

        nativeBuildInputs = with pkgs; [rustStable];
      };
    });
}
