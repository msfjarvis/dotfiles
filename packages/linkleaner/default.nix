{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "3.0.0";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-uIATfH7KN+RJKLPJIT1+0IK2rEwY1YoXpv+yrL70i80=";
  };

  cargoHash = "sha256-O+ZwBb8U7nCUWPtEX+mpxT4djoeszlJ1F8diGDyDgAw=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
