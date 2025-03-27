{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.22.85d964f-unstable-2025-03-26";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "d608ee0a7594e3c83cdb087e81002f176d0d7008";
    hash = "sha256-zaM1t4aeKvQnav/vO7iiNyrenxI1S3yvMH+mU4qqGtc=";
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
