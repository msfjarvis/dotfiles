{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "8a21fca2c650cd77d1b1d358dacd1ef02ca0d813";
    hash = "sha256-8zdgdUAb1YleBwt0/JX/2pjKIbDQmSdHqdc5vnR5Woo=";
  };
in
python3.pkgs.buildPythonApplication {
  pname = "cyberdrop-dl";
  version = "10.3.0-unstable-2026-08-08";
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
