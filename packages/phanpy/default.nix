{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.08.08.e6a2887-unstable-2026-09-02";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "ed960c6f027c2d4f56c90d2efab0f4658b7466d0";
    hash = "sha256-3xbVErr7r27Kyj3bJAJgHQTpbgriaTytU4FcEqUfMgE=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-add-a-2-in-1-fav-boost-button.patch
    # Fix for the scrolling bug
    ./0002-fix-carousel-make-carousels-focusable-so-keyboard-sc.patch
  ];

  npmDepsHash = "sha256-0Xfs4BSfKuPVW8fB1vO9AF6zaN6/v6RrGzAUljS6OIo=";

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
