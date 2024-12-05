{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "5.7.2-unstable-2024-12-04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "490631aacc0a6d98e0ef4f38d8b995f3173adf07";
    hash = "sha256-O8lPRUeCqzvccKg9nipCYqOV23b1nPKE/CkoBYe0CjI=";
  };

  patches = [ ./unpin-dependencies.patch ];

  postPatch = ''
    # pyreadline3 is Windows-only
    substituteInPlace pyproject.toml \
      --replace-fail 'pyreadline3 = "^3.5.4"' ""
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    aenum
    aiofiles
    aiohttp
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
