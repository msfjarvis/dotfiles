{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.13.0";
in
rustPlatform.buildRustPackage {
  pname = "linkleaner";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "linkleaner";
    rev = "v${version}";
    hash = "sha256-KW83Q7gdeSZ2pUM7ZOygwwUe6eW7851QHlgIcoLpRkE=";
  };

  cargoHash = "sha256-hVTCzgWLsa4Wf1rRP70OXOroxgHEcqVNfuLm/swwGCQ=";

  useNextest = true;

  meta = with lib; {
    description = "A Telegram bot with an identity crisis";
    homepage = "https://msfjarvis.dev/g/linkleaner/";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "linkleaner";
  };
}
