{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "zizmor";
  version = "0.10.0-unstable-2024-12-31";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "zizmor";
    rev = "4f6d939257bfa2eeeec468bad06d9c48b2a5728e";
    hash = "sha256-a659wlOm8mY1XaUqu+GZLbOj0U0JPG3BXh/gIPftB5U=";
  };

  cargoHash = "sha256-MzBuhslC1pXQJWetZGpXjboFYoOVNa8jVjim3OdGvf4=";

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
