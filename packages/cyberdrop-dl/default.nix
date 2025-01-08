{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "6.0.1-unstable-2025-01-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "30a03db33a6f2a2f94873ac5e02727ebd42c2007";
    hash = "sha256-N2pcbNZLtKqQYL/6pX6pLJI1odjZPBsyW9Aa4bpVt8c=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail 'aiohttp = "^3.11.10"' 'aiohttp = "^3.11.9"'
    substituteInPlace pyproject.toml --replace-fail 'aiolimiter = "^1.2.1"' 'aiolimiter = "^1.1.0"'
    substituteInPlace pyproject.toml --replace-fail 'aiosqlite = "0.17.0"' 'aiosqlite = "0.20.0"'
    substituteInPlace pyproject.toml --replace-fail 'asyncpraw = "^7.8.0"' 'asyncpraw = "^7.7.1"'
    substituteInPlace pyproject.toml --replace-fail 'certifi = "^2024.12.14"' 'certifi = "^2024.8.30"'
    substituteInPlace pyproject.toml --replace-fail 'pycryptodomex = "^3.21.0"' 'pycryptodomex = "^3.20.0"'
    substituteInPlace pyproject.toml --replace-fail 'pydantic = "^2.10.4"' 'pydantic = "^2.10.3"'
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    aenum
    aiofiles
    aiohttp
    aiohttp-client-cache
    aiolimiter
    aiosqlite
    apprise
    arrow
    asyncpraw
    beautifulsoup4
    certifi
    filedate
    get-video-properties
    inquirerpy
    jeepney
    lz4
    mediafire
    mutagen
    myjdapi
    pillow
    platformdirs
    pycryptodomex
    pydantic
    pyyaml
    rich
    send2trash
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
