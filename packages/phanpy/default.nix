{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.10.09.febb38d-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "2ea14a10308e172877b96d9d03a22f67923d1f2d";
    hash = "sha256-Kst5nKTuhhMqmSarEQruCwr/8+/gXQ+X6V23k7Omt2Q=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-add-a-2-in-1-fav-boost-button.patch
    # Fix for the scrolling bug
    ./0002-fix-carousel-make-carousels-focusable-so-keyboard-sc.patch
  ];

  npmDepsHash = "sha256-VFXRPOjMz+pEcP3CJDpf1VK/Az8D/n6jBubl9n/F0vQ=";

  postPatch = ''
    substituteInPlace vite.config.js \
      --replace-fail "            name: 'messages:extract:clean'," $'            name: \'messages:extract:clean\',\n            build: false,'
  '';

  npmRebuildFlags = [ "--ignore-scripts" ];

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
