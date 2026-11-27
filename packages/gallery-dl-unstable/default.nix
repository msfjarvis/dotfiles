{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.21-unstable-2026-11-26";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "25ca0bd2e60087da1f431c0a226e8de12ea7e9a3";
    hash = "sha256-OSbchSKybOChSHk+VA3yZl63cL4/qhlp6V1KCXiIbuI=";
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
