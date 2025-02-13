{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-12";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "8fb6d47c9f07ac625ae10a9da0b86466268ae039";
    hash = "sha256-eotXCTLTW14IJw3S+ppzajt63iOWrsD9HM1npqXbPPA=";
  };

  npmDepsHash = "sha256-pyys6/Eyl1yRlbQrbxCQG090rlu3WNd6/268f7r3kUo=";

  installPhase = ''
    mkdir $out
    pushd dist || exit 1
    cp -vR ./ $out/
  '';

  PHANPY_WEBSITE = lib.optionalString (defaultUrl != null) defaultUrl;

  meta = {
    description = "A minimalistic opinionated Mastodon web client ";
    homepage = "https://github.com/cheeaun/phanpy";
    license = lib.licenses.mit;
    # Nothing to run here
    mainProgram = null;
  };
}
