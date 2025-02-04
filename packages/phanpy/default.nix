{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-03";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "79641b47a52216ecbd805d289ec16bf4cb2e1e69";
    hash = "sha256-46aWXVdnmccgh/Q0XPbIc3OsHl9ohGwrrlHO3vMO8dQ=";
  };

  npmDepsHash = "sha256-laavBcYFiJ4YplZqox2RFt1qC7EG2wG2f05LIC++DFc=";

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
