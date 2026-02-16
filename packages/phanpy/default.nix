{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.01.31.8b98d5a-unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "da473a8bf4d78296fa14d30a26ecbaf84e59a93c";
    hash = "sha256-o0j2GMiq+ZMKbQedt+8urk3rYZSG6Pn/RUL9Ssa9A24=";
  };

  patches = [
    # (fetchpatch2 {
    #   # https://github.com/cheeaun/phanpy/issues/1085
    #   url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
    #   hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    # })
  ];

  npmDepsHash = "sha256-/M11VSS5I42S9/42/4RAj3PxkG97SssyxLzkwaa66zk=";

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
