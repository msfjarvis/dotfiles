{
  lib,
  python3,
  gnused,
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

  postPatch =
    let
      sed = lib.getExe gnused;
      # Convert python3.12-aiohttp-3.11.9 to aiohttp
      mkRealName =
        pkg: pkg.pname |> lib.removePrefix "${python3.libPrefix}-" |> lib.removeSuffix "-${pkg.version}";
      mkPatch =
        pkg:
        ''${sed} -i 's/${mkRealName pkg} = ".*"/${mkRealName pkg} = "^${pkg.version}"/' pyproject.toml'';
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
