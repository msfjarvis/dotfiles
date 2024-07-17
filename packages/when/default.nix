{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "0.4.0";
in
rustPlatform.buildRustPackage {
  pname = "when";
  inherit version;

  src = fetchFromGitHub {
    owner = "mitsuhiko";
    repo = "when";
    rev = version;
    hash = "sha256-JvnvGD14VOXu0+xVMF4aQLvgOFLxNsebCSgKZLycHUw=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-HhxAk5pLOpn2cRDoPkrxyV27n6IGAI2vkep9j3o275I=";

  useNextest = true;

  meta = with lib; {
    description = "Timezones from the command line";
    homepage = "https://github.com/mitsuhiko/when";
    changelog = "https://github.com/mitsuhiko/when/blob/${version}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "when";
  };
}
