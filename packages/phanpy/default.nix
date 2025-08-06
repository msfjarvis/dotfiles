{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.07.18.3f4b1a6-unstable-2025-08-05";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "738c20eceaa9dbbd4cd8aa3ec9bf6c7fe826e576";
    hash = "sha256-2mTJeCXInrtrWfAz3ct5JXHdmJQgCIlGeH9xQx1MAdU=";
  };

  patches = [
    (fetchpatch2 {
      # https://github.com/cheeaun/phanpy/issues/1085
      url = "https://github.com/sm32d/phanpy/commit/1d50be6834d68d09a76b47e23b7584dd5b0cd4e6.patch";
      hash = "sha256-C3L10o0s7dx7bRMoqOOGSyA3oLfMyVMSRlvgd/AAG1c=";
    })
  ];

  npmDepsHash = "sha256-/i2Zf9QZHwta1n+BGWMHudG+2/J1DzmVpa4ABWGpisk=";

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
