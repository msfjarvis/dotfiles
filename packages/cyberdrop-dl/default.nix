{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.6.42-unstable-2024-10-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "cyberdropdownloader";
    rev = "8667de24ffd8eb923fb94384ce864a152754da5d";
    hash = "sha256-mCa9jgRR8DDQHM/3ZF8w+qySo/otqU9U9oYXOSAu/So=";
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
