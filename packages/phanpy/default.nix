{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2025.10.09.079936b-unstable-2025-10-28";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "6b175a529caee0c76b50e9d2d891c3b8ce90920c";
    hash = "sha256-F4Mfo9maiUFJuazG3RCfj/iTt7f50sfSpPICTdAZ2bA=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    })
  ];

  npmDepsHash = "sha256-E8gjFz6W/vv7QTCRGeveP4fwxgDecNeegmcI/wJy7Sk=";

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
