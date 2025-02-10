{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "5.0.0";
in
rustPlatform.buildRustPackage {
  pname = "adx";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-oE7LHZdIoDPRzhbJoiMPwQvIwKmNm4mZa7X19j5qybg=";
  };

  cargoHash = "sha256-yzruNIkvlJyU3DRM/iFArnUW5BEVZmmGmH44gtmRBlQ=";
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
