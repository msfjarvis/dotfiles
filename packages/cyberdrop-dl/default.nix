{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "7.3.0-unstable-2025-07-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "6b7a7413c74b0ce2923b52c0b31c9e4d02f03a30";
    hash = "sha256-knOBoVo2t2mghqMeLirDjm4Pw5BMxkzypEuaXGFls7o=";
  };

  patches = [ ./disable-update-check.diff ];

  pythonRelaxDeps = [
    "aiosqlite"
    "certifi"
    "curl-cffi"
    "dateparser"
  ];

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
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
