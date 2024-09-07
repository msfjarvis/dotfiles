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
  version = "0.2.2";
  rev = "950f5dbe5b920af620a6120d1713848bb954578c";
in
rustPlatform.buildRustPackage {
  pname = "gitout";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gitout";
    inherit rev;
    hash = "sha256-lUai0pqLsRxAB+aH0dO6d66f4ccHGPRsRPWUWPA0i3w=";
  };

  cargoHash = "sha256-ZTmf98OUdlIwPFPFVrgJa+VV7BIxZuwekuFiF8vOQKo=";

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
    ++ lib.optionals stdenv.isDarwin (
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
