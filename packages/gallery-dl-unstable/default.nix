{
  lib,
  python3,
  fetchFromForgejo,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallery-dl-unstable";
  version = "1.32.21-unstable-2026-11-21";
  pyproject = true;

  src = fetchFromForgejo {
    domain = "git.msfjarvis.dev";
    owner = "msfjarvis";
    repo = "gallery-dl";
    rev = "43819a93d146a8bee6325df79e839a92e699dfeb";
    hash = "sha256-xyNbp6LbH0V8FOyas+8DHSE3cYxFTCuSKoMQIDhumbI=";
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
