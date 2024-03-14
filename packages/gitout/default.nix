{
  pkgs,
  lib,
}: let
  inherit (pkgs) rustPlatform fetchFromGitHub pkg-config libgit2 openssl zlib stdenv darwin;
in
  rustPlatform.buildRustPackage rec {
    pname = "gitout";
    version = "0.2.1";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "gitout";
      rev = "v${version}";
      hash = "sha256-XrHgnpYpUQd+oCRcY+Lt7ETRCfjz1KOaHOtQidut1bw=";
    };

    cargoHash = "sha256-fjsLqi/s6yco6jf2s/9g/4R2THdXZCDxp/5OR09zRL4=";

    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs =
      [
        libgit2
        openssl
        zlib
      ]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.Security
      ];

    meta = with lib; {
      description = "A command-line tool and Docker image to automatically backup Git repositories from GitHub or anywhere";
      homepage = "https://github.com/msfjarvis/gitout";
      changelog = "https://github.com/msfjarvis/gitout/blob/${src.rev}/CHANGELOG.md";
      license = licenses.mit;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "gitout";
    };
  }
