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
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "nickoehler";
    repo = "mediafire_rs";
    rev = "v${version}";
    hash = "sha256-RboRyysEn+u0BGJR5wA7WtczQqwWTZVXWxWFvBHoMjg=";
  };

  cargoHash = "sha256-5sI/UyH80KqemAN4rSVhs6NRIyYMER6V7e0BYmmzBDI=";

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
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mdrs";
  };
}
