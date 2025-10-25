{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "8.4.0-unstable-2025-10-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "26d8b2e8fae18d8c502da2703da6ea5adb562e5c";
    hash = "sha256-HQIPw8O9j8hnh8hVgEqoHDnAnWOxPsRQwnH0IlT/Wso=";
  };

  pythonRelaxDeps = map (p: p.pname) dependencies;

  build-system = [
    python313.pkgs.poetry-core
  ];

  dependencies = with python313.pkgs; [
    aiofiles
    aiohttp
    aiohttp-client-cache
    aiolimiter
    aiosqlite
    apprise
    arrow
    asyncpraw
    beautifulsoup4
    browser-cookie3
    certifi
    curl-cffi
    dateparser
    get-video-properties
    imagesize
    inquirerpy
    m3u8
    mediafire
    myjdapi
    packaging
    pillow
    platformdirs
    propcache
    psutil
    pycares
    pydantic
    pyyaml
    rich
    send2trash
    truststore
    xxhash
    yarl
  ];

  pythonImportsCheck = [
    "cyberdrop_dl"
  ];

  meta = {
    description = "Bulk Gallery Downloader for Cyberdrop.me and Other Sites";
    homepage = "https://github.com/jbsparrow/CyberDropDownloader";
    changelog = "https://github.com/jbsparrow/CyberDropDownloader/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cyberdrop-dl";
  };
}
