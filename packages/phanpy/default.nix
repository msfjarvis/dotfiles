{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-11";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "ccf99245071c07e3551bbc9fb079c770dbc755e0";
    hash = "sha256-w/te8SmhlnQzTPNUq7oURjFOnVN1IS1A9zbr9pwRLRI=";
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
