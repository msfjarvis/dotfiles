{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "0cff7326dbc3cc25cb7286c5a4e78f5757050707";
    hash = "sha256-64bYnryctTW7EQxPQ2+iFD5N0gNh7AXo8Evz2yDdKPI=";
  };
in
python3.pkgs.buildPythonApplication {
  pname = "cyberdrop-dl";
  version = "10.7.0-unstable-2026-09-02";
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
