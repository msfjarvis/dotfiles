{
  pkgs,
  lib,
}: let
  inherit (pkgs) stdenvNoCC fetchurl;
in
  stdenvNoCC.mkDerivation rec {
    pname = "diffuse-bin";
    version = "0.1.0";
    src = fetchurl {
      url = "https://github.com/JakeWharton/diffuse/releases/download/${version}/diffuse-${version}-binary.jar";
      hash = "sha256-YNYZNzxGpdBrgSbB1h4K3Bi3Lyy7kkXvkg0zh+RLhs8=";
    };

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      printf "#!/bin/sh\n\nexec java \$JAVA_OPTS -jar \$0 \"\$@\"\n" > $out/bin/diffuse
      cat $src >> $out/bin/diffuse
      chmod +x $out/bin/diffuse
    '';

    meta = with lib; {
      description = "Diffuse is a tool for diffing APKs, AABs, AARs, and JARs";
      homepage = "https://github.com/jakewharton/diffuse";
      license = licenses.asl20;
      platforms = platforms.all;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "diffuse";
    };
  }
