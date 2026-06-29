{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "mediafire-rs";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "nickoehler";
    repo = "mediafire_rs";
    rev = "v${version}";
    hash = "sha256-paya2POttFNZDaAM0PFAAufGoG/xwYUqJw/P7Mk6gbk=";
  };

  cargoHash = "sha256-dsOSO7J+XnFVnbzH1kIHdttGd16e199lRjUk6KrHPuA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # Tests use the Mediafire API
  doCheck = false;

  meta = {
    description = "Async rust rewrite of mediafire_bulk_downloader";
    homepage = "https://github.com/nickoehler/mediafire_rs";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mdrs";
  };
}
