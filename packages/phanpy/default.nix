{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.03.12.4e6820d-unstable-2025-03-19";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "82903087a45826e2f6fb817ae74d9f935d67efdb";
    hash = "sha256-/aH1Lbj2WnHH50V7Q8YRu2sxJzGkbcxy3hxE88S9jvk=";
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
