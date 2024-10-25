{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.6.54-unstable-2024-10-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "cyberdropdownloader";
    rev = "101859454b58451ac04f7a515e1a0b423afda8bd";
    hash = "sha256-IC97n/NwE/OdHLiAquZ3y6YXohp2FBu2dBTyyDDL0b4=";
  };

  patches = [ ./unpin-dependencies.patch ];

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    aiohttp
    aiolimiter
    aiosqlite
    arrow
    asyncpraw
    beautifulsoup4
    browser-cookie3
    certifi
    filedate
    get-video-properties
    humanfriendly
    inquirerpy
    mediafire
    mutagen
    myjdapi
    pillow
    platformdirs
    pyyaml
    rich
    send2trash
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
