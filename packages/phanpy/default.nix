{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.01.31.8b98d5a-unstable-2026-02-22";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "c530de38f5763837773c727e54bd6f91b927b3bb";
    hash = "sha256-mabwTkIKIAL/wovnshTxT8Wh7E3vmdw1vUnkKrUGRas=";
  };

  patches = [
    # (fetchpatch2 {
    #   # https://github.com/cheeaun/phanpy/issues/1085
    #   url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
    #   hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    # })
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
