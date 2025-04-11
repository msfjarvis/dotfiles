{
  lib,
  python3,
  gnused,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "6.8.0-unstable-2025-04-10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "c17e7124dfc543f8196d1766239c49dce3b8da28";
    hash = "sha256-LQwinksQNSDbS7VI4M8EgbSsIzl7iTrVfTHIDsRShZM=";
  };

  patches = [ ./disable-update-check.diff ];

  postPatch =
    let
      sed = lib.getExe gnused;
      # Convert python3.12-aiohttp-3.11.9 to aiohttp
      mkRealName =
        pkg: lib.removePrefix "${python3.libPrefix}-" (lib.removeSuffix "-${pkg.version}" pkg.pname);
      mkPatch =
        pkg: ''${sed} -i 's/\s*"${mkRealName pkg}.*"/"${mkRealName pkg}==${pkg.version}"/' pyproject.toml'';
    in
    lib.concatStringsSep "\n" (lib.lists.map mkPatch dependencies);

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
    browser-cookie3
    certifi
    curl-cffi
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
    psutil
    pycryptodomex
    pydantic
    pyyaml
    rich
    send2trash
    textual
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
