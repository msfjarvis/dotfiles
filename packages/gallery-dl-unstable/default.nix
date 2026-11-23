{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.21-unstable-2026-11-22";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "ea4236d1de99caff58c42a17df6b79972bd215f6";
    hash = "sha256-dV/A8KiOLXJ483kMf0qGbs9rjeTjDqG36nf7wS6xeDo=";
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
