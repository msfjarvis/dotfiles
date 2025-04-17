{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.22.85d964f-unstable-2025-04-17";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "ea2829dafc29d9e29cb176c443aa9bb6653d9cd3";
    hash = "sha256-+8FzAgo/q6iYXEUV7s6xCUN+MpLfUNQUS2A70/+gyQU=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-lVH3ZcnnJen34dLxSMYp5D8QQCRPRSEZIJPrg2FiA28=";
    })
  ];

  npmDepsHash = "sha256-dBYpmRfpm3nFOFmyCMSTVFvic5IJ7GSucvO+F3WJWyo=";

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
