{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "2024.12.28.119d4b0";
in
stdenvNoCC.mkDerivation {
  name = "phanpy";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cheeaun/phanpy/releases/download/${version}/phanpy-dist.tar.gz";
    hash = "sha256-9E2hr+f0hfNeSZcErdm4EZIOj5G+7ftqg4zJh/mFcUQ=";
  };
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    tar xvzf $src -C $out
  '';

  meta = {
    description = "A minimalistic opinionated Mastodon web client ";
    homepage = "https://github.com/cheeaun/phanpy";
    license = lib.licenses.mit;
    # Nothing to run here
    mainProgram = null;
  };
}
