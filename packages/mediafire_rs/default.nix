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
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "nickoehler";
    repo = "mediafire_rs";
    rev = "v${version}";
    hash = "sha256-poRanHyPX9HpqenJv6rkyqPX7OUcuAmR1enn52mUAiE=";
  };

  cargoHash = "sha256-lGtOt6X57fAi01vHwlYVfVq3ptn4gRLYohmuzHUDU2M=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
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
