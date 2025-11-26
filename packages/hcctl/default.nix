{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.2.0";
in
rustPlatform.buildRustPackage {
  pname = "hcctl";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "hcctl-v${version}";
    hash = "sha256-lc9zSZcXVEHdRP2D5HAPGy4UDdDI+CD2VoUK1o2qElM=";
  };

  buildAndTestSubdir = "hcctl";

  cargoHash = "sha256-RzSFnuoE3EnibeAyMgt4QVcfEawtWgnCKG0wXV9ds8c=";

  useNextest = true;

  meta = with lib; {
    description = "Simple CLI tool to keep a track of your https://healthchecks.io account";
    homepage = "https://msfjarvis.dev/g/healthchecks-rs";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "hcctl";
  };
}
