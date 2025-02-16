{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "adb-sync";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adb-sync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uoIueSbhml6lHgpI6OH1Y4cNeZzzTBS+PAPHf62xJzY=";
  };

  outputs = [ "out" ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -m755 -D adb-sync $out/bin/adb-sync
    install -m755 -D adb-channel $out/bin/adb-channel
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/google/adb-sync";
    description = "adb-sync is a tool to synchronize files between a PC and an Android device using the ADB (Android Debug Bridge)";
    license = licenses.asl20;
    platforms = platforms.all;
    mainProgram = "adb-sync";
  };
})
