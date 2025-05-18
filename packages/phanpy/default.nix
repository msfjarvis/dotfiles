{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.04.28.5849b4d-unstable-2025-05-18";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "4f57ba8c2a86e63c97578bb267b52c519d2359d9";
    hash = "sha256-IMwD8ZrW3zifAnTrXp7jsaFlYWmlbV8BRAw2G/SlSnE=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    })
  ];

  npmDepsHash = "sha256-1vcCHmp3Tz5zw3VOVDE5DGB5CyO9PrA1L1WsYTK26iE=";

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
