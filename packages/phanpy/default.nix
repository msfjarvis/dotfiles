{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-03-04";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "fb2c7d5ef7d797e6b9ee892378849ae654c43962";
    hash = "sha256-DBnEHu6ISp+L0i1TTjmNCbHh+ieuD3jvyDW/C6BYnOk=";
  };

  npmDepsHash = "sha256-1faItl+LsUGmBmznUSog3TLRYbbCCadFzlpa30w/xOQ=";

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
