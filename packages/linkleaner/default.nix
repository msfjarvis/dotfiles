{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  aws-lc,
  lib,
}:
let
  version = "3.2.1";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-5FVLH+8NzWOsBtiztBKQyy+r1H5w3n4PLqCTJjM7U30=";
  };

  cargoHash = "sha256-RIynMNaitHx2WjOHqLFGUoVVIQIHjTQ725UnWy8FWCo=";

  useNextest = true;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ aws-lc ];

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
