{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "3.1.0";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-VAgpB4lXk6jcau+ejfWXRCi+pBfdefpRKAz3lKhNh0w=";
  };

  cargoHash = "sha256-0fDAk6Jsp3RF2VlY9OBcSqEJUcRgptIpBzpPEXkSrnE=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
