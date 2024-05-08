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
rustPlatform.buildRustPackage rec {
  pname = "gitout";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gitout";
    rev = "v${version}";
    hash = "sha256-lUai0pqLsRxAB+aH0dO6d66f4ccHGPRsRPWUWPA0i3w=";
  };

  cargoHash = "sha256-ZTmf98OUdlIwPFPFVrgJa+VV7BIxZuwekuFiF8vOQKo=";

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  meta = with lib; {
    description = "A command-line tool and Docker image to automatically backup Git repositories from GitHub or anywhere";
    homepage = "https://github.com/msfjarvis/gitout";
    changelog = "https://github.com/msfjarvis/gitout/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "gitout";
  };
}
