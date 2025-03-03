{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.0.4";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-jXYN2akIGVt9a6hFPWAcKHVlJpGx/G1o/4AYmk+/5UU=";
  };

  cargoHash = "sha256-CNwzQWmec8/HVKldZFbIXz3WYiO/BDXS2wiyXTuY+Qs=";
  useFetchCargoVendor = true;

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
