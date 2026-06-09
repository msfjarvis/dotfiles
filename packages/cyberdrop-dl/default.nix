{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "ec8c0d36374abd98bec535ebe49d0e92c81a7e23";
    hash = "sha256-bRNy5m0T7iMYPin1OA3GGD54XKLm+XUd8+78qukpgo8=";
  };
in
python3.pkgs.buildPythonApplication {
  pname = "cyberdrop-dl";
  version = "9.15.0.dev0-unstable-2026-06-08";
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
