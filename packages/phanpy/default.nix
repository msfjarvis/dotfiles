{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2024.12.28.119d4b0-unstable-2025-01-25";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "de0da11cc0c8fd030e9536653c9515daa78accdf";
    hash = "sha256-TSvTXGeJoUlpg7EEHfQnAR26lTIQwbIPGYsos+itSNw=";
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
