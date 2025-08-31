{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.8.1";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-3l9jr+s3O+izNi1K05DKz5R/ggoeon0ddCqe+f+1m/g=";
  };

  cargoHash = "sha256-AAFBoQcDVrNBY+3PXmYZ+1OJ+Dv7EzBkP8AY9V8ppiY=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
