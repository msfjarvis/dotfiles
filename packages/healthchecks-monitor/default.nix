{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  version = "3.1.0";
in
rustPlatform.buildRustPackage {
  pname = "healthchecks-monitor";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "healthchecks-monitor-v${version}";
    hash = "sha256-6N++Kkb6XR/zNNbkkonZFGrTuu3c0XAbX/eHhvX3nM0=";
  };

  buildAndTestSubdir = "monitor";

  cargoHash = "sha256-UzvLBzd5CgVON1mz/d1Cy+M81IOpl1omRJnxX1se56w=";

  useNextest = true;

  meta = with lib; {
    description = "CLI tool to run shell jobs and report status to https://healthchecks.io";
    homepage = "https://msfjarvis.dev/g/healthchecks-rs";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "healthchecks-monitor";
  };
}
