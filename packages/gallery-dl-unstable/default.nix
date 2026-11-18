{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.20-unstable-2026-11-17";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "09e62c3dbeb75edf161e21b8c77f2e6dde297bf5";
    hash = "sha256-7HWXOZUOeWM7Vazg1UjmqayCn/VMwHzNAwCCAEE/wqo=";
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
