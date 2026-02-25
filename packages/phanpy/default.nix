{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.02.24.48b2cf7-unstable-2026-02-22";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "b89d0d367625b3e1a5f6f6b261872421d0e01f02";
    hash = "sha256-/aICPzpuolqt2B+9pTMKQLFJQDW40eZf/XmwqMDdf/Q=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-1085-add-a-2-in-1-fav-boost-button.patch
  ];

  npmDepsHash = "sha256-WTQUgP0TiGU8zFvXy4FGfGrjfk3tdhpTlMQ99EFpAV0=";

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
