{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-08";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "398cbbefac4aae3aafbd75473c61eabdec81ae6a";
    hash = "sha256-NBpy4L0NAVZLcLiRtqfz5YDH+pgeczAod89q7DOeClE=";
  };

  npmDepsHash = "sha256-laavBcYFiJ4YplZqox2RFt1qC7EG2wG2f05LIC++DFc=";

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
