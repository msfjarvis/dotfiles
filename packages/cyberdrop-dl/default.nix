{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "8.9.0-unstable-2025-12-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "17f6f7ccc6ee5624cc177607c8e923f51eec82fd";
    hash = "sha256-2NcP1X4OLblyP3eHqJP2Sq9ctxmBuR7Vcfw2PKVZ1ps=";
  };

  pythonRelaxDeps = map (p: p.pname) dependencies;

  build-system = [
    python313.pkgs.poetry-core
  ];

  dependencies = with python313.pkgs; [
    aiodns
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
