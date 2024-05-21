{
  pkgs,
  fetchFromGitHub,
  makeRustPlatform,
  stdenv,
  darwin,
  lib,
  inputs,
}:
let
  inherit (inputs) fenix rust-manifest;
  inherit ((import fenix { inherit pkgs; })) fromManifestFile;

  toolchain = (fromManifestFile rust-manifest).minimalToolchain;
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  rec {
    pname = "linkleaner";
    version = "2.3.1";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-wHc1Jq9XiSz2KhCZv/SG0vMU17qus7zRs7OalHFTeGc=";
    };

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "teloxide-0.12.2" = "sha256-rU428fU6mMX0QzT9OVDJQ7qUc5PLw/ZRFPOsoq+2ys8=";
      };
    };

    cargoHash = "sha256-9oAC+B3uboNyIvk/C5WLlPZT/d4FgSKrGIMw40cbxEE=";

    useNextest = true;

    meta = with lib; {
      description = "A Telegram bot with an identity crisis";
      homepage = "https://msfjarvis.dev/g/linkleaner/";
      license = licenses.mit;
      platforms = platforms.all;
      mainProgram = "linkleaner";
    };
  }
