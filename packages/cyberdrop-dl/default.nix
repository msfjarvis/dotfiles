{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "7.5.0-unstable-2025-09-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "f0bc85d7c42066f3d9f30f88bdd4ef104f2c4222";
    hash = "sha256-lt94e2Sed2s4FOPdVvGuTdhPlx3Y/3hYepOlvb7QGyk=";
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
    inquirerpy
    m3u8
    mediafire
    myjdapi
    packaging
    pillow
    platformdirs
    psutil
    pycares
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
    maintainers = [ ];
    mainProgram = "cyberdrop-dl";
  };
}
