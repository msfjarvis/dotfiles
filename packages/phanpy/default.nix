{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.06.23.05dcc55-unstable-2026-06-24";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "c3a493de01d87f6f9f19cd481f9aa973d89b69f1";
    hash = "sha256-9shXDbTyNYqa3a36tIpMGNIvUbaXm5wW78uMtxAh5gk=";
  };

  patches = [
    # Rebased copy of PR 1096
    ./0001-add-a-2-in-1-fav-boost-button.patch
    # Fix for the scrolling bug
    ./0002-fix-carousel-make-carousels-focusable-so-keyboard-sc.patch
  ];

  npmDepsHash = "sha256-apfs4Fco/XoEaY5Tjz6d0ZlOULyLZFN/QV80RYVNP0o=";

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
