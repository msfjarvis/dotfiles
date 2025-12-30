{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2025.11.26.ac85274-unstable-2025-12-29";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "1e5bc081f91f41c57973b36f1cf982f08ca89486";
    hash = "sha256-zztVO11dIjBwca13lw0JhzLr/ou9Uaz1dzXKUchqD5w=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    })
  ];

  npmDepsHash = "sha256-4CRW2Dc9fDzIJqsPL6KOB0JTq7ybATg4xr8oDinz5tE=";

  installPhase = ''
    mkdir $out
    pushd dist || exit 1
    cp -vR ./ $out/
  '';

  postPatch = ''
    # If we keep the `exifreader` section then the buildscript will try to call NPM again
    # which breaks the Nix sandbox assumptions and fails to build.
    cat <<< $(${lib.getExe jq} 'del(.exifreader)' package.json) > package.json
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
