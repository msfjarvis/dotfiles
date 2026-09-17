{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.11.1";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-thwqubTZCcVl+lOHMxQcWr4F0YvCa3X0Vx+KZsWc7gA=";
  };

  cargoHash = "sha256-0IPnw/BQhyqvZ65aoDYQ6L0GnNe3XAqvqDeaiEEvVPo=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
