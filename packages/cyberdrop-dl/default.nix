{
  lib,
  python3,
  gnused,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cyberdrop-dl";
  version = "6.5.0-unstable-2025-02-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jbsparrow";
    repo = "CyberDropDownloader";
    rev = "2428ec5a3486143190d6c1978adb29f05878569e";
    hash = "sha256-X+JqUlnA1YLvQXJ4xlzyviK9zzzFBwW4M0znY5UAlk0=";
  };

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
