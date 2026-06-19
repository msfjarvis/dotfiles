{
  lib,
  python3,
  fetchFromCodeberg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.3-unstable-2026-06-18";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "4147023aa26faa9853b254d1f17dfe5121acacc4";
    hash = "sha256-18zwfLaHMOEUEZI6qBnILkMLZqR694fyNXFDWq4QaZ0=";
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
