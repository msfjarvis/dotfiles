{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "zizmor";
  version = "unstable-2024-12-25";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "zizmor";
    rev = "c28d44c9032f0983829e217470d7c9b57804ddfe";
    hash = "sha256-M/ZR/aFcVU6U6fyQjzbCFCWCC35xMrd464XVW7lFjts=";
  };

  cargoHash = "sha256-RL9eAr31uRaboN8K7xz0r45KDDk9C6Ocq6TzRCfcHMk=";

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
