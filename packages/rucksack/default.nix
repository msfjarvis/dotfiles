{
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
let
  version = "1.1.1";
in
rustPlatform.buildRustPackage {
  pname = "rucksack";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "rucksack";
    rev = "v${version}";
    hash = "sha256-oZJGXR33SxvysrKTEz2ds0CwI3cjDYHJC7UWwOiq3g4=";
  };

  buildFeatures = lib.optionals stdenv.isLinux [ "journald" ];
  cargoHash = "sha256-Aijv7Zs/wbksRJsF2uMcLjdFjnxzhFcTAvy9kJi5cVI=";

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
