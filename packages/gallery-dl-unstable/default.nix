{
  lib,
  python3,
  fetchFromCodeberg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.19-unstable-2026-11-01";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "47808904b071af889c47dca406e9a0e14baf2e19";
    hash = "sha256-bfqI918eUJGNKGtcCB3Rgxmj2RdftYs7Evvo8YVD2fQ=";
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
