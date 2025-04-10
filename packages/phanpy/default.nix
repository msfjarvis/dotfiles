{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.22.85d964f-unstable-2025-04-09";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "51260b6e192f560c190f995f116a1e7f27976bf7";
    hash = "sha256-xg78064cqO0HkRkMhM8AfTAShPmYxsPJvhyx4XEithk=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-lVH3ZcnnJen34dLxSMYp5D8QQCRPRSEZIJPrg2FiA28=";
    })
  ];

  npmDepsHash = "sha256-eVn/rZNQdT6SF/yCiTLcpjzM7T6KVyz4+pE0xz+hv0w=";

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
