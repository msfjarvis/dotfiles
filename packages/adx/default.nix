{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.1.0";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-CClV3YFJGu3sD6d7NsGtum9fM9PEjf+8vE39Iq0m/H8=";
  };

  cargoHash = "sha256-abNknbPXyUH47nZHwa4lN+JabmlmQr9YOsC9KILUUlU=";

  # Tests are annoying to make work with buildRustPackage
  doCheck = false;

  meta = with lib; {
    description = "Rust tooling to poll Google Maven repository for updates to AndroidX artifacts";
    homepage = "https://github.com/msfjarvis/adx";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "adx";
  };
}
