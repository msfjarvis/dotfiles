{
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
let
  version = "1.2.1";
in
rustPlatform.buildRustPackage {
  pname = "rucksack";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "rucksack";
    rev = "v${version}";
    hash = "sha256-MdIGtHw4xrvVYUUcC3hjNz+eVYA2F1UBZ7pIWYcY38s=";
  };

  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "journald" ];
  cargoHash = "sha256-B0nokvnz3ypWW3P6b7MHhI7dEx9xTJmnzhyn83JBOHA=";

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
