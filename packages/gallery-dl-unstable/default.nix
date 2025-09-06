{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.30.5-unstable-2025-09-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "752f82f002c8f3b1c8128f5dc8f799b615327716";
    hash = "sha256-mMhws/kQtAYqBQYUgcp+UOu1E0YAvVl49b8aJ3YJh1E=";
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
