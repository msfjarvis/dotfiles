{
  pkgs,
  lib,
}: let
  inherit (pkgs) fetchFromGitHub rustPlatform stdenv;
in
  rustPlatform.buildRustPackage rec {
    pname = "rucksack";
    version = "1.1.1";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "rucksack";
      rev = "v${version}";
      hash = "sha256-oZJGXR33SxvysrKTEz2ds0CwI3cjDYHJC7UWwOiq3g4=";
    };

    buildFeatures = lib.optionals stdenv.isLinux ["journald"];
    cargoHash = "sha256-Aijv7Zs/wbksRJsF2uMcLjdFjnxzhFcTAvy9kJi5cVI=";

    useNextest = true;

    meta = with lib; {
      description = "Simple CLI tool to watch directories and move their files to a single dumping ground";
      homepage = "https://github.com/msfjarvis/rucksack";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "rucksack";
    };
  }
