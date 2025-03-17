{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.12.4e6820d-unstable-2025-03-16";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "6ac064fa37a8d5e659a98462bbdcf27f6da9354b";
    hash = "sha256-2ymLisrDDIWOQvhQLuDLQPkrsr+MbuVTXdlV14bTG4I=";
  };

  npmDepsHash = "sha256-1faItl+LsUGmBmznUSog3TLRYbbCCadFzlpa30w/xOQ=";

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
