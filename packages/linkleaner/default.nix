{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.9.1";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-8AUZBGMXYoI0CwA7pCx6Np9RDhzbqldiH32I3O7XsNE=";
  };

  cargoHash = "sha256-cxZBx8MkdiUHwVuLnt4DrkiI3aq/AXMNWbUxB/6f0bo=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
