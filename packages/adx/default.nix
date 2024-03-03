{
  pkgs,
  lib,
}: let
  inherit (pkgs) darwin fetchFromGitHub rustPlatform stdenv;
in
  rustPlatform.buildRustPackage rec {
    pname = "adx";
    version = "4.5.1";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "adx";
      rev = "v${version}";
      hash = "sha256-oDvi1bEARtki4pMRh99cgoEtGJ5S0e33yU9/lKZKRSs=";
    };

    cargoHash = "sha256-Y8quDq4dz9m92g0xrjb2KZ3BIlJwrH3CtCgY78wpCiA=";

    useNextest = true;

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

    meta = with lib; {
      description = "Rust tooling to poll Google Maven repository for updates to AndroidX artifacts";
      homepage = "https://github.com/msfjarvis/adx";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "adx";
    };
  }
