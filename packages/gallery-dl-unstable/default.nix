{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.30.10-unstable-2025-12-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "9a8746f12df9efa5a61ebd4e685925a06cccd154";
    hash = "sha256-o2OgMdm8ahAr0z8Blqn1NWOybRcyO4dIXomLSS66X84=";
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
