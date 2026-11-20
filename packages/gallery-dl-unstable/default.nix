{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.20-unstable-2026-11-19";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "4b34b123cf1792436789b36d67f369ea85647257";
    hash = "sha256-0S1yekGnlMHeg78n8mTZRXwTnWzy/6aWW5DJMCXzXUg=";
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
