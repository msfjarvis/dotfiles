{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2024.12.28.119d4b0-unstable-2025-01-24";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "d0862cecb686cfb8280f5d466783d18eab91e9cc";
    hash = "sha256-ez2XRC3uQq2yXOjFzvglgIiLhV0uj2qBWLLg/k776iI=";
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
