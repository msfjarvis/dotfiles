{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.30.2-unstable-2025-08-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "16acfbd1e7eb1bc4bc4de7335577db850b3a5ca1";
    hash = "sha256-cxsjjtb8XLYSxRMZCkUpMDdffdDHHnHZINQqHRSQy30=";
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
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gallery-dl";
  };
}
