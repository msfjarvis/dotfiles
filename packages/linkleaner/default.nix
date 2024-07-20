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

  version = "2.3.10";
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    pname = "linkleaner";
    inherit version;

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-wMuIYyguk5x9z9mjeuIVBU2lf3mUfT5lZ0gpgfZugSg=";
    };

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "teloxide-0.12.2" = "sha256-t2pXDKsDrKAhdaHsOcMQBZc3NalDod5UZz991vHShwE=";
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
