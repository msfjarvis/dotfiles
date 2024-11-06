{
  stdenvNoCC,
  fetchurl,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "diffuse-bin";
  version = "0.1.0";
  src = fetchurl {
    url = "https://github.com/JakeWharton/diffuse/releases/download/${finalAttrs.version}/diffuse-${finalAttrs.version}-binary.jar";
    hash = "sha256-YNYZNzxGpdBrgSbB1h4K3Bi3Lyy7kkXvkg0zh+RLhs8=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    printf "#!/bin/sh\n\nexec java \$JAVA_OPTS -jar \$0 \"\$@\"\n" > $out/bin/diffuse
    cat $src >> $out/bin/diffuse
    chmod +x $out/bin/diffuse
    runHook postInstall
  '';

  meta = with lib; {
    description = "Diffuse is a tool for diffing APKs, AABs, AARs, and JARs";
    homepage = "https://github.com/jakewharton/diffuse";
    license = licenses.asl20;
    platforms = platforms.all;
    mainProgram = "diffuse";
  };
})
