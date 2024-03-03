{
  pkgs,
  lib,
}: let
  inherit (pkgs) stdenvNoCC fetchFromGitHub;
in
  stdenvNoCC.mkDerivation rec {
    pname = "adb-sync";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "adb-sync";
      rev = "v${version}";
      hash = "sha256-uoIueSbhml6lHgpI6OH1Y4cNeZzzTBS+PAPHf62xJzY=";
    };

    outputs = ["out"];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      install -m755 -D adb-sync $out/bin/adb-sync
      install -m755 -D adb-channel $out/bin/adb-channel
    '';

    meta = with lib; {
      homepage = "https://github.com/google/adb-sync";
      description = "adb-sync is a tool to synchronize files between a PC and an Android device using the ADB (Android Debug Bridge)";
      license = licenses.asl20;
      platforms = platforms.all;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "adb-sync";
    };
  }
