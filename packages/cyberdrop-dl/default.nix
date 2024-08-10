{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.3.41-unstable-2024-08-10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "cyberdropdownloader";
    rev = "458eb07e1c20b70d6c057dd7de59b1a6d7f69694";
    hash = "sha256-8WRZYYykYtV6Xf3mOA7RoCCzIQ6CQ/SLjefCYDCkJWY=";
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
