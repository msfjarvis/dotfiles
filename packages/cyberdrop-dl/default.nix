{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "191da6a352d79485817118a317338db809dec2ce";
    hash = "sha256-0EpSyZS8fHyfUBDjvf4M0ktVlZzK+4mMhhT4f9KOEOo=";
  };
in
python3.pkgs.buildPythonApplication {
  pname = "cyberdrop-dl";
  version = "10.9.1-unstable-2026-09-17";
  inherit src;

  pyproject = true;

  pythonRelaxDeps = true;

  postPatch = ''
    sed -ie 's/requires = \["uv_build[^"]*"]/requires = ["uv_build"]/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.uv-build
  ];

  dependencies = with python3.pkgs; [
    aiodns
    aiofiles
    aiohttp
    aiolimiter
    aiosqlite
    async-mega-py
    backports-zstd
    beautifulsoup4
    certifi
    curl-cffi
    cyclopts
    dateparser
    imagesize
    inquirer
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
    questionary
    readchar
    rich
    send2trash
    truststore
    urllib3
    wassima
    xxhash
    yarl
  ];

  pythonImportsCheck = [
    "cyberdrop_dl"
  ];

  meta = {
    description = "Bulk Gallery Downloader for Cyberdrop.me and Other Sites";
    homepage = "https://github.com/Cyberdrop-DL/cyberdrop-dl";
    changelog = "https://github.com/Cyberdrop-DL/cyberdrop-dl/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "cyberdrop-dl";
  };
}
