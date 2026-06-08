{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.2.0";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-yUz673sk1UP8jkFsHyetoBN4FPW8ZeDo8WDdw5SIw6k=";
  };

  cargoHash = "sha256-Dfw5MdiSW+seF5Lq7JUYYQ+hozvfF1x9q2eyc050oac=";

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
