{
  lib,
  python3,
  fetchFromCodeberg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.13-unstable-2026-09-24";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "564b5c1347ff0e13f2dc804528d96e06894ea9a4";
    hash = "sha256-YemLQQcDXeaHqEC4FcRIczRfesiIOO0577En3ZtGp6A=";
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
