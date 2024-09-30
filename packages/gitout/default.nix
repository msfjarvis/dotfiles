{
  rustPlatform,
  fetchFromGitHub,
  perl,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  stdenv,
  darwin,
  lib,
}:
let
  version = "0.2.2-unstable-2024-09-29";
  rev = "6ed891a55aedea4d1620fab45721c4b4130756dc";
in
rustPlatform.buildRustPackage {
  pname = "gitout";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gitout";
    inherit rev;
    hash = "sha256-b8h3vFmFk3ppN3KO7PzJRIWzgTLqVEZH5n2Zm7zVTyM=";
  };

  cargoHash = "sha256-AFKJohUNPcI9D8DRxGTfAHr7hPlZLnNoNrx6cjojaXI=";

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs =
    [
      libgit2
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        Security
        SystemConfiguration
      ]
    );

  meta = with lib; {
    description = "A command-line tool and Docker image to automatically backup Git repositories from GitHub or anywhere";
    homepage = "https://github.com/msfjarvis/gitout";
    changelog = "https://github.com/msfjarvis/gitout/blob/${rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "gitout";
  };
}
