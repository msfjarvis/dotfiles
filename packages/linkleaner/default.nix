{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.10.1";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-nlCUjnbRuHeefNJz6CZSdGAbILraFSgrpaI4Oe+lxl0=";
  };

  cargoHash = "sha256-X3qZa7E04qNi996DCHZZzI/buGLZ/LkLEltIpy53LjU=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
