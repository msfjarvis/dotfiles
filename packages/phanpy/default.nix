{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "2024.12.08.7e1ffc5";
in
stdenvNoCC.mkDerivation {
  name = "phanpy";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cheeaun/phanpy/releases/download/${version}/phanpy-dist.tar.gz";
    hash = "sha256-J49M8+IeJ5faW0UAuuvpXMKnqxpsPjtLoQOGVkkIfU8=";
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
