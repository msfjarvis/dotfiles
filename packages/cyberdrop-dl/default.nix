{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.7.0-unstable-2024-11-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "cyberdropdownloader";
    rev = "b14d1c56bb5f961d97840dd92e51ee17f41108bd";
    hash = "sha256-2W+bFyccO6enysyAuq7rnd4bS9jZ5yFyYec/XeOX2tM=";
  };

  patches = [ ./unpin-dependencies.patch ];

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    aiohttp
    aiolimiter
    aiosqlite
    apprise
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
