{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  version = "3.2.0";
in
rustPlatform.buildRustPackage {
  pname = "healthchecks-monitor";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "healthchecks-monitor-v${version}";
    hash = "sha256-lc9zSZcXVEHdRP2D5HAPGy4UDdDI+CD2VoUK1o2qElM=";
  };

  buildAndTestSubdir = "monitor";

  cargoHash = "sha256-RzSFnuoE3EnibeAyMgt4QVcfEawtWgnCKG0wXV9ds8c=";

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
