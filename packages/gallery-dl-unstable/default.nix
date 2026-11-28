{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.21-unstable-2026-11-27";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "85435263e38f7d2a2c0c2efb2b02c233bfce30f2";
    hash = "sha256-HG4Za9zKnskYx1T7V/FVXG52tydVAyboJrND/SFlZCM=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    requests
  ];

  pythonImportsCheck = [
    "gallery_dl"
  ];

  meta = {
    description = "Command-line program to download image galleries and collections from several image hosting sites";
    homepage = "https://git.msfjarvis.dev/msfjarvis/gallery-dl";
    changelog = "https://git.msfjarvis.dev/msfjarvis/gallery-dl/src/commit/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "gallery-dl";
  };
})
