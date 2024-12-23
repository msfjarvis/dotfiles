{
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
let
  version = "1.2.0";
in
rustPlatform.buildRustPackage {
  pname = "rucksack";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "rucksack";
    rev = "v${version}";
    hash = "sha256-UhKRqjybeMOpy7oxsTsEAejwPTP32aBBNr/2AsgMWaY=";
  };

  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "journald" ];
  cargoHash = "sha256-moYh0zvLy3rL0YZEB7p60Q05zbnm/ML4u1SPg/DLzck=";

  useNextest = true;

  meta = with lib; {
    description = "Simple CLI tool to watch directories and move their files to a single dumping ground";
    homepage = "https://github.com/msfjarvis/rucksack";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "rucksack";
  };
}
