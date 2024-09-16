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
  version = "0.2.2-unstable-2024-09-15";
  rev = "a90a7f7efafe2bfc666df4a5eb9a8337bc311dc1";
in
rustPlatform.buildRustPackage {
  pname = "gitout";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gitout";
    inherit rev;
    hash = "sha256-idQ8SQWFZ8i9D+5pb40Qwb8NHaXW7mlf0pQf7NteztI=";
  };

  cargoHash = "sha256-XkEnDkGQktIpUlMkA99ZVBJQuuH8MaUTk4L7tGB4k1Y=";

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
