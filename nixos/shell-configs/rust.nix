{
  description = "My Rust Project";

  inputs = {
    nixpkgs = {url = "github:NixOS/nixpkgs/nixpkgs-unstable";};

    flake-utils = {url = "github:numtide/flake-utils";};

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    flake-utils,
    advisory-db,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };

      rustStable =
        pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      craneLib = (crane.mkLib pkgs).overrideToolchain rustStable;
      commonArgs = {
        src = craneLib.cleanCargoSource ./.;
        buildInputs = [];
        nativeBuildInputs = [];
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        cargoToml = ./my-rust-package/Cargo.toml;
      };
      cargoArtifacts = craneLib.buildDepsOnly (commonArgs // {doCheck = false;});

      my-rust-package = craneLib.buildPackage (commonArgs // {doCheck = false;});
      my-rust-package-clippy = craneLib.cargoClippy (commonArgs
        // {
          inherit cargoArtifacts;
        });
      my-rust-package-fmt = craneLib.cargoFmt (commonArgs // {});
      my-rust-package-audit = craneLib.cargoAudit (commonArgs // {inherit advisory-db;});
      my-rust-package-nextest = craneLib.cargoNextest (commonArgs
        // {
          inherit cargoArtifacts;
          src = ./.;
          partitions = 1;
          partitionType = "count";
        });
    in {
      checks = {
        inherit my-rust-package my-rust-package-audit my-rust-package-clippy my-rust-package-fmt my-rust-package-nextest;
      };

      packages.default = my-rust-package;

      apps.default = flake-utils.lib.mkApp {drv = my-rust-package;};

      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks;

        nativeBuildInputs = with pkgs; [
          cargo-nextest
          cargo-release
          rustStable
        ];

        CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
      };
    });
}
