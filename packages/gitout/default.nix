{
  pkgs,
  lib,
}: let
  inherit (pkgs) rustPlatform fetchFromGitHub pkg-config libgit2 openssl zlib stdenv darwin;
in
  rustPlatform.buildRustPackage rec {
    pname = "gitout";
    version = "0.2.0";

    src = fetchFromGitHub {
      owner = "JakeWharton";
      repo = "gitout";
      rev = version;
      hash = "sha256-V9Rmwdd03NSgD21WcVf2qto1F7juX6IryM3NrERh37M=";
    };

    cargoHash = "sha256-72bG12a+svq3b6lYu+ZRFtrWzZiv+JpR93BTPJOe3Hw=";

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
      homepage = "https://github.com/JakeWharton/gitout";
      changelog = "https://github.com/JakeWharton/gitout/blob/${src.rev}/CHANGELOG.md";
      license = licenses.mit;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "gitout";
    };
  }
