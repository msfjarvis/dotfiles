{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.0.1";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-/VeOoPvxxpQRO39C6KBLUpvkh1FozAdxFdfgQBgO67I=";
  };

  cargoHash = "sha256-R75cznEktr+2sSqspABF9DzPqDAZ0p6v/m8LGGeXI1I=";
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
