{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "3.2.0";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-ugadHILcO+PiotbkYWIR7ozwsDU64dX2F1Q3uKDK2CQ=";
  };

  cargoHash = "sha256-H2L0T7vlPkuBevxlcHV1YeFFMYtVhzPkEaWLQT1tOU8=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
