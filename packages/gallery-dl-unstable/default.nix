{
  lib,
  python3,
  fetchFromCodeberg,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.2-unstable-2026-06-11";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "50a1e69c501ab3b7f53223133b86521f5c1fb40c";
    hash = "sha256-s9l8pLHWIm4TNmKNdpqJU4YJtug5maYZ98ZGF3gNhdU=";
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
