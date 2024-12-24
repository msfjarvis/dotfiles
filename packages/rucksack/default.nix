{
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
let
  version = "1.2.2";
in
rustPlatform.buildRustPackage {
  pname = "rucksack";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "rucksack";
    rev = "v${version}";
    hash = "sha256-fvxdPOyJIRDt26QuticY+EMhjWM5QRpp4by7uuf5lTY=";
  };

  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "journald" ];
  cargoHash = "sha256-tEkWan50+HN87IdI8/gTEuAKvcj3SGz39m7o8+/0Xms=";

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
