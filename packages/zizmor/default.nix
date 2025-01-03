{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "zizmor";
  version = "1.0.0-unstable-2025-01-02";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "zizmor";
    rev = "211540ce2eb7ce705eb0c65066bc3c1d074caa90";
    hash = "sha256-wEwG/aCkRFhSD5/H6o+Lf+0Nr8cyL1KCR8B3AFY7p50=";
  };

  cargoHash = "sha256-tKJW5eafM+In6bntw1G2OgmPaLUgbPTBk21C5/jWzls=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = {
    description = "A static analysis tool for GitHub Actions";
    homepage = "https://github.com/woodruffw/zizmor";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "zizmor";
  };
}
