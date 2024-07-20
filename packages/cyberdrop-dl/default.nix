{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.3.40-unstable-2024-07-17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "cyberdropdownloader";
    rev = "e42a11637abfe14bfe2c2ae467284f1b113ea041";
    hash = "sha256-VnKLbU4JEr6ctBBfagvrtpbZn+8u4H75xucU3TumIN4=";
  };

  patches = [ ./unpin-dependencies.patch ];

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    aiohttp
    aiolimiter
    aiosqlite
    asyncpraw
    beautifulsoup4
    browser-cookie3
    certifi
    filedate
    get-video-properties
    inquirerpy
    mediafire
    mutagen
    myjdapi
    pillow
    platformdirs
    pyyaml
    rich
  ];

  pythonImportsCheck = [ "cyberdrop_dl" ];

  meta = with lib; {
    description = "Bulk Gallery Downloader for Cyberdrop.me and Other Sites";
    homepage = "https://github.com/jbsparrow/cyberdropdownloader";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "cyberdrop-dl";
  };
}
