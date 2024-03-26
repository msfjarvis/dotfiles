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
    version = "1.9.1";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-jf8OelykdhKnREDf+B2z0KriHVSF0uih6huByvzm3+k=";
    };

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "teloxide-0.12.2" = "sha256-QjkpEwqEPyisirX/8h5VtU8zFd6oCh1AuahE+lHnoT0=";
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
