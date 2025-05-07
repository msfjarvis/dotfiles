{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.04.28.5849b4d-unstable-2025-05-06";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "7bbbf9c4f0a79eada7479ab57d026dcb94183a42";
    hash = "sha256-K8wTICsZfqZSTsH2v27C3XaWeJ649RbOqsEO0Gn7+oI=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    })
  ];

  npmDepsHash = "sha256-4NhpfPkbMOJPFdiSdofs0RLL0rHe9gEkbgc/jCiBIVs=";

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
