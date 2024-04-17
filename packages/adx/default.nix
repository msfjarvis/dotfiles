{
  pkgs,
  lib,
}: let
  inherit (pkgs) darwin fetchFromGitHub rustPlatform stdenv;
in
  rustPlatform.buildRustPackage rec {
    pname = "adx";
    version = "4.5.4";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "adx";
      rev = "v${version}";
      hash = "sha256-/T3Kd11nHiBVTPyk9C7GztO/+xUK2xfrZLGSJ8E101k=";
    };

    cargoHash = "sha256-D8LFtU0xxsY4m58PTvKVJKvsxB8OfA4fDqpNEZG3aEI=";

    # Tests are annoying to make work with buildRustPackage
    doCheck = false;

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    meta = with lib; {
      description = "Rust tooling to poll Google Maven repository for updates to AndroidX artifacts";
      homepage = "https://github.com/msfjarvis/adx";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "adx";
    };
  }
