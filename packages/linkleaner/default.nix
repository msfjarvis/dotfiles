{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.12.0";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-7sGTGHnt2iZFy9x3WnACtyg5eLUzUJ2/OB2zvkWKSIU=";
  };

  cargoHash = "sha256-FGPGnH5em1ODI/GnKcXDP+4PZUIyfiZWDzW0C2r0xh0=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
