{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.9.6";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-sDt8Ey+SYQXTy1orqQQe5VRLsT43r8B0jidjMKyXz7E=";
  };

  cargoHash = "sha256-jDqKJU/6oOQaQ+7cMWxfaUL0AWQdl1OEwbR/2fEr70M=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
