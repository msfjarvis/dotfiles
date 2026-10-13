{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.10.09.febb38d-unstable-2026-10-13";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "7f83a0660bbc0b89ab90fb3ec84c4a6d88d6bea9";
    hash = "sha256-74aQdRTEz4+S8xuM+IDvhbqeIW192EjuXnQ6h2hV62Y=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-add-a-2-in-1-fav-boost-button.patch
    # Fix for the scrolling bug
    ./0002-fix-carousel-make-carousels-focusable-so-keyboard-sc.patch
  ];

  npmDepsHash = "sha256-PNsFeOOyzv3u/4TA6FgP1GrwVXAAKYpsFskjmHHxs7k=";

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
