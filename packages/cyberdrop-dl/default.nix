{
  lib,
  python313,
  fetchFromGitHub,
}:

python313.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "8.1.0-unstable-2025-09-29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "01db4f764dee51bd3cf87c1bc6ca88bec96728a8";
    hash = "sha256-zZT0TMXGPBfO0a/5FmCRrZLkLZpJiapoDjipitK4S1g=";
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
