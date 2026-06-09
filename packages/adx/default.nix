{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.2.1";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-hcH6s5Cj1+R21XyOQZY0UH2i5GFjJV2IBq1NgMtFbM8=";
  };

  cargoHash = "sha256-4RWcBiUFYyv3KHtGHmtXsp7DnThOrx6FzKENDL+zM8I=";

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
