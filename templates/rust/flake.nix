{
  description = "package definition and devshell for my-rust-package";

  inputs.nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.advisory-db.url = "github:rustsec/advisory-db";
  inputs.advisory-db.flake = false;

  inputs.crane.url = "github:ipetkov/crane";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  inputs.fenix.url = "github:nix-community/fenix";
  inputs.fenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.flake-compat.url = "git+https://git.lix.systems/lix-project/flake-compat";
  inputs.flake-compat.flake = false;

  outputs =
    {
      nixpkgs,
      advisory-db,
      crane,
      devshell,
      fenix,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };

        rustStable = (import fenix { inherit pkgs; }).fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
        };

        craneLib = (crane.mkLib pkgs).overrideToolchain rustStable;
        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          buildInputs = [ ];
          nativeBuildInputs = [ ];
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        };
        cargoArtifacts = craneLib.buildDepsOnly (commonArgs // { doCheck = false; });

        my-rust-package = craneLib.buildPackage (commonArgs // { doCheck = false; });
        my-rust-package-clippy = craneLib.cargoClippy (commonArgs // { inherit cargoArtifacts; });
        my-rust-package-fmt = craneLib.cargoFmt (commonArgs // { });
        my-rust-package-audit = craneLib.cargoAudit (commonArgs // { inherit advisory-db; });
        my-rust-package-nextest = craneLib.cargoNextest (
          commonArgs
          // {
            inherit cargoArtifacts;
            src = ./.;
            partitions = 1;
            partitionType = "count";
          }
        );
      in
      {
        checks = {
          inherit
            my-rust-package
            my-rust-package-audit
            my-rust-package-clippy
            my-rust-package-fmt
            my-rust-package-nextest
            ;
        };

        packages.default = my-rust-package;

        apps.default = flake-utils.lib.mkApp { drv = my-rust-package; };

        devShells.default = pkgs.devshell.mkShell {
          bash = {
            interactive = "";
          };

          env = [
            {
              name = "DEVSHELL_NO_MOTD";
              value = 1;
            }
          ];

          packages = with pkgs; [
            cargo-nextest
            cargo-release
            rustStable
            stdenv.cc
          ];
        };
      }
    );
}
