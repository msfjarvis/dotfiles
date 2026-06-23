{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.06.22.d8e5db7-unstable-2026-06-22";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "289b89a6d2a6a60b7a804a656c210bb81a798edf";
    hash = "sha256-t4l9hwxiTG/QHqXs1ecPcukJ7ut4+Cv3S12bf+Ypv9Q=";
  };

  npmDepsHash = "sha256-zwl7qCo/Nhu2dMgwFP0YFD7MZmtyKIYNsIXCTNcyWAU=";

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
