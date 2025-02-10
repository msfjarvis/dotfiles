{
  rustPlatform,
  fetchFromGitHub,
  perl,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  lib,
}:
let
  version = "0.2.3";
  rev = "3b35f0e3dd7022ddf8574e5bd587d2afc0ab4e66";
in
rustPlatform.buildRustPackage {
  pname = "gitout";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gitout";
    inherit rev;
    hash = "sha256-JIv61I2ZB7Pzaufg2/Fohsfe/mZ6mLVJwGtopEFr/6w=";
  };

  cargoHash = "sha256-b/5koKvq0aa8u9G5XtDuMf1jzuDUnJE3yrUV2FJafnM=";
  useFetchCargoVendor = true;

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  meta = with lib; {
    description = "A command-line tool and Docker image to automatically backup Git repositories from GitHub or anywhere";
    homepage = "https://github.com/msfjarvis/gitout";
    changelog = "https://github.com/msfjarvis/gitout/blob/${rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "gitout";
  };
}
