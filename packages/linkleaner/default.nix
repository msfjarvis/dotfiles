{
  pkgs,
  lib,
  inputs,
}: let
  inherit (pkgs) fetchFromGitHub makeRustPlatform stdenv darwin;
  inherit (inputs) rust-manifest;
  inherit ((import inputs.fenix {inherit pkgs;})) fromManifestFile;

  toolchain = (fromManifestFile rust-manifest).minimalToolchain;
in
  (makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  })
  .buildRustPackage rec {
    pname = "linkleaner";
    version = "1.9.0";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-CagMcRpjyMq0/a7pKMCESa0NzuwskCTHWwtSvFtO1uM=";
    };

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "teloxide-0.12.2" = "sha256-4GRyFlDQIdm3EgjLgTh1oVZ8X5Vyes4tigvKIb7UO5c=";
      };
    };

    cargoHash = "sha256-9oAC+B3uboNyIvk/C5WLlPZT/d4FgSKrGIMw40cbxEE=";

    useNextest = true;

    meta = with lib; {
      description = "A Telegram bot with an identity crisis";
      homepage = "https://msfjarvis.dev/g/linkleaner/";
      license = licenses.mit;
      platforms = platforms.all;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "linkleaner";
    };
  }
