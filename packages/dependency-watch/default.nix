{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jre,
  makeWrapper,
  ...
}:
let
  self = stdenv.mkDerivation (finalAttrs: {
    pname = "dependency-watch";
    version = "0.7.0";

    src = fetchFromGitHub {
      owner = "JakeWharton";
      repo = "dependency-watch";
      rev = "${finalAttrs.version}";
      hash = "sha256-lR/z/khw2IvFYf6sQaggIzV2n7rSsGBeYAFkpe5JP3E=";
    };

    nativeBuildInputs = [
      gradle
      makeWrapper
    ];

    mitmCache = gradle.fetchDeps {
      pkg = self;
      data = ./deps.json;
    };

    # this is required for using mitm-cache on Darwin
    __darwinAllowLocalNetworking = true;

    gradleFlags = [ "-Dfile.encoding=utf-8" ];

    gradleBuildTask = "assemble";

    doCheck = true;

    installPhase = ''
      binFile=$out/bin/${finalAttrs.pname}
      libDir=$out/share/${finalAttrs.pname}/

      mkdir -p $out/bin $libDir

      mv -v build/install/${finalAttrs.pname}/lib/ $libDir

      CLASSPATH=""
      for i in $libDir/lib/*; do
        if [[ -n "$CLASSPATH" ]]; then
          CLASSPATH="$CLASSPATH:$i"
        else
          CLASSPATH="$i"
        fi
      done

      makeWrapper ${lib.getExe jre} $binFile \
        --add-flags "-classpath $CLASSPATH" \
        --add-flags "watch.dependency.Main"
    '';

    meta.sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  });
in
self
