{
  lib,
  python3,
  fetchpatch2,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gallery-dl-unstable";
  version = "1.28.5-unstable-2025-02-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "1d3b9a9e4065bab55738693c69ed7f2fb0e6a918";
    hash = "sha256-rrFor8A1v1kz4UYONeDJM5ovuajJslh/Q6RjRfBScUI=";
  };

  patches = [
    (fetchpatch2 {
      name = "unbreak-bunkr";
      url = "https://patch-diff.githubusercontent.com/raw/mikf/gallery-dl/pull/7070.patch?full_index=1";
      hash = "sha256-5WkMOD5vWH2+rlVPuXeDmb5fto/+4f3sUt8VpVVvjgU=";
    })
  ];

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
