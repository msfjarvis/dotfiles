{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "8cab7357aa5dc3f21d7b0aa3feb2441578bc5b7b";
    hash = "sha256-HGinoksBFrqZNE1+o6bRp+Faa9YrUWwJqHOsOZ2fcec=";
  };
in
python3.pkgs.buildPythonApplication {
  pname = "cyberdrop-dl";
  version = "10.0.1-unstable-2026-07-01";
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
    readchar
    rich
    send2trash
    truststore
    urllib3
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
