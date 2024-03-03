{
  pkgs,
  lib,
}: let
  inherit (pkgs) stdenvNoCC fetchurl;
in
  stdenvNoCC.mkDerivation rec {
    pname = "monocraft-nerdfonts";
    version = "3.0";
    src = fetchurl {
      url = "https://github.com/IdreesInc/Monocraft/releases/download/v${version}/Monocraft-nerd-fonts-patched.ttf";
      hash = "sha256-QxMp8UwcRjWySNHWoNeX2sX9teZ4+tCFj+DG41azsXw=";
    };

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/share/fonts/truetype/
      cat $src > $out/share/fonts/truetype/Monocraft-nerdfonts.ttf
    '';

    meta = with lib; {
      description = "A monospaced programming font inspired by the Minecraft typeface";
      homepage = "https://github.com/IdreesInc/Monocraft";
      license = licenses.ofl;
      platforms = platforms.all;
      maintainers = with maintainers; [msfjarvis];
    };
  }
