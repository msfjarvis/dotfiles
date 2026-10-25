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
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "nickoehler";
    repo = "mediafire_rs";
    rev = "v${version}";
    hash = "sha256-21X19KRIWAIJ6AU0a/UJeytIphbN6tQ8Q0+Kx9QnefQ=";
  };

  cargoHash = "sha256-DenxW5MuK8uVhD08us+Kthun9jr88+Oc/wI3L7GyqT8=";

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
