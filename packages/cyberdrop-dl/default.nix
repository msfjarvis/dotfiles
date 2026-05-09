{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "9.7.1.dev2-unstable-2026-05-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Cyberdrop-DL";
    repo = "cyberdrop-dl";
    rev = "72583906451fffe9f6d0f17097d4f9903576604e";
    hash = "sha256-CTN+lf7+RWZZNGBkXt2cdzaXGR8bBrudfHbBk+uGJAQ=";
  };

  pythonRelaxDeps = map (p: p.pname) dependencies;

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
