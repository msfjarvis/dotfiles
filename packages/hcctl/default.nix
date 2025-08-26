{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.1.0";
in
rustPlatform.buildRustPackage {
  pname = "hcctl";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "hcctl-v${version}";
    hash = "sha256-nhdh3DNoiWodmDjMpDn2oUjV5imD4rpRnyrgGstVKxo=";
  };

  buildAndTestSubdir = "hcctl";

  cargoHash = "sha256-xP1J9YCroxcALepGImG48By90/bejYqbClNQ1w+UcS0=";

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
