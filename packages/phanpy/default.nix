{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.08.08.e6a2887-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "0340050401a5e19d8c3dd3fde319ee6c81ff3799";
    hash = "sha256-hUd3v98WiiWJHl/Z/FtUXnEXTEK/vc6UNUpcoVid+J8=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-add-a-2-in-1-fav-boost-button.patch
    # Fix for the scrolling bug
    ./0002-fix-carousel-make-carousels-focusable-so-keyboard-sc.patch
  ];

  npmDepsHash = "sha256-l8NTXDqf9QoLlHxq/+6nvhq2cz2UpThui6YTYaMpbO4=";

  postPatch = ''
    substituteInPlace vite.config.js \
      --replace-fail "            name: 'messages:extract:clean'," $'            name: \'messages:extract:clean\',\n            build: false,'
  '';

  npmRebuildFlags = [ "--ignore-scripts" ];

  preBuild = ''
    npm run generate-icons
  '';

  installPhase = ''
    mkdir $out
    pushd dist || exit 1
    cp -vR ./ $out/
  '';

  PHANPY_WEBSITE = lib.optionalString (defaultUrl != null) defaultUrl;

  meta = {
    description = "A minimalistic opinionated Mastodon web client ";
    homepage = "https://github.com/cheeaun/phanpy";
    license = lib.licenses.mit;
  };
}
