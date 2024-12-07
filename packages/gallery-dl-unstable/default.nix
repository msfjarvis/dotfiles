{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.28.0-unstable-2024-12-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "34e157e166373fbae893396162aec7c60fa9f654";
    hash = "sha256-tFYyBvnmupOvOkIddfEiFN1kRbMdkNG9dlf8h2GX/50=";
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
