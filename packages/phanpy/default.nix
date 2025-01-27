{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-01-26";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "ffbd07b5d8383e8a600d6cf5ac1ab181be7c9b56";
    hash = "sha256-XZrhULl6hmnuP8E2eb4hzWCUpCyLCUflU67F9lpBUwU=";
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
