{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "zizmor";
  version = "0.10.0-unstable-2024-12-28";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "zizmor";
    rev = "238e30dd61b89f64f7edef28cba176f1917000b8";
    hash = "sha256-F9y5LFQkCRESjG103bQLImzqW7nRqP/k9lJPiosGMso=";
  };

  cargoHash = "sha256-1M3G/SlnA/Ta4SlVUNlQ4IOkj9e5mhpFzcFas3UFxIk=";

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
