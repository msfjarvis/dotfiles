{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.12.4e6820d-unstable-2025-03-13";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "fbf510cb0dd8cc449546c2a2435984b3ef4e3588";
    hash = "sha256-OWwPT4SXdETvvVLg7hZNlll47d8wKUdMXjy6OLpo3DQ=";
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
