{
  pkgs,
  lib,
}: let
  inherit (pkgs) fetchFromGitHub rustPlatform stdenv;
in
  rustPlatform.buildRustPackage rec {
    pname = "rucksack";
    version = "1.0.8";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "rucksack";
      rev = "v${version}";
      hash = "sha256-MpDfvNdD/tdOZ3sIoGRAC8hOFimylvWy/MuxZgZqU7M=";
    };

    buildFeatures = lib.optionals stdenv.isLinux ["journald"];
    cargoHash = "sha256-lv2KcEQqERa+brQXVWwjaeLdqPDTa4ZLVwQZo+jqv0Y=";

    useNextest = true;

    meta = with lib; {
      description = "Simple CLI tool to watch directories and move their files to a single dumping ground";
      homepage = "https://github.com/msfjarvis/rucksack";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "rucksack";
    };
  }
