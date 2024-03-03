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
    version = "1.8.3";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-lxKMmSySY5EbnK7GccoFBcQGaqkuir95nVOJkd4L08s=";
    };

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

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
