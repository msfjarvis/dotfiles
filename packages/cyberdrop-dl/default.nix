{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "7.3.1-unstable-2025-08-09";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "0a738053f9f3e1f8e182cce48f8dde18d7e05739";
    hash = "sha256-zur1ZRznmsGZ5E1eLOzbQZ9xl6Rg/y1eZrVPaGN0qyU=";
  };

  patches = [ ./disable-update-check.diff ];

  pythonRelaxDeps = [
    "aiosqlite"
    "certifi"
    "curl-cffi"
    "dateparser"
  ];

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
    inquirerpy
    m3u8
    mediafire
    myjdapi
    pillow
    platformdirs
    psutil
    pydantic
    pyyaml
    rich
    send2trash
    truststore
    xxhash
  ];

  pythonImportsCheck = [
    "cyberdrop_dl"
  ];

  meta = {
    description = "Bulk Gallery Downloader for Cyberdrop.me and Other Sites";
    homepage = "https://github.com/jbsparrow/CyberDropDownloader";
    changelog = "https://github.com/jbsparrow/CyberDropDownloader/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cyberdrop-dl";
  };
}
