{
  pkgs,
  lib,
}: let
  inherit (pkgs) buildGoModule fetchFromGitHub;
in
  buildGoModule rec {
    pname = "adbtuifm";
    version = "0.5.8";

    src = fetchFromGitHub {
      owner = "darkhz";
      repo = "adbtuifm";
      rev = "v${version}";
      hash = "sha256-TK93O9XwMrsrQT3EG0969HYMtYkK0a4PzG9FSTqHxAY=";
    };

    vendorHash = "sha256-voVoowjM90OGWXF4REEevO8XEzT7azRYiDay4bnGBks=";

    ldflags = ["-s" "-w"];

    meta = with lib; {
      description = "A TUI File Manager for ADB";
      homepage = "https://github.com/darkhz/adbtuifm";
      license = licenses.mit;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "adbtuifm";
    };
  }
