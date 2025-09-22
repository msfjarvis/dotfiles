{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.30.7-unstable-2025-09-21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "8d672fb1ea63c7481f03e0cec5f920329706b890";
    hash = "sha256-RNCCHVbXjEVBM4AnBoC3X8WfoLxh9e3ST5m7C47H66Y=";
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
    homepage = "https://github.com/mikf/gallery-dl";
    changelog = "https://github.com/mikf/gallery-dl/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "gallery-dl";
  };
}
