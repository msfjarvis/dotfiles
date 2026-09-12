{
  lib,
  python3,
  fetchFromCodeberg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.11-unstable-2026-09-11";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "d5f3379eb4b0e44d34fd8e628d944985a840a00a";
    hash = "sha256-vQeV2acQwu/GIFCHp37h6O6tLK+UAXnGmmuRPfJKlJU=";
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
    homepage = "https://codeberg.org/mikf/gallery-dl";
    changelog = "https://codeberg.org/mikf/gallery-dl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "gallery-dl";
  };
})
