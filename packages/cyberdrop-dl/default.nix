{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "8.10.0-unstable-2026-03-13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "31b3f7b6798aa9e2f9d20c0cb7bc2bcfdfc5b8f2";
    hash = "sha256-kLatwGQOhE5kVrh2DLmzmujVSCggZQ5BXJSMsq8GIoQ=";
  };

  pythonRelaxDeps = map (p: p.pname) dependencies;

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    aiodns
    aiofiles
    aiohttp
    aiolimiter
    aiosqlite
    async-mega-py
    beautifulsoup4
    certifi
    curl-cffi
    dateparser
    imagesize
    inquirerpy
    jeepney
    m3u8
    myjdapi
    packaging
    propcache
    psutil
    pycares
    pycryptodome
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
