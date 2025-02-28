{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-27";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "44bfbd35d940923322219c7b02322fa083ca2119";
    hash = "sha256-1o4GOORR2p7ynqLJppcnXOXcSodbPqJ/UI2rHs5CbLo=";
  };

  npmDepsHash = "sha256-u30KkPXTRFlvXs5redqOfx+DL+HxLtJ6opeuLZRiuUk=";

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
