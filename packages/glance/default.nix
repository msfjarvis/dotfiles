{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-10-30";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "863d4f117b16638806cf995a6faf0a15a0f4e339";
    hash = "sha256-psSgu5nd33OJGR3Yhr/z6aTjxJOcseGqHloN72WzCMo=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-i26RD3dIN0pEnfcLAyra2prLhvd/w1Qf1A44rt7L6sc=";

  excludedPackages = [ "build-and-ship" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A self-hosted dashboard that puts all your feeds in one place";
    homepage = "https://github.com/glanceapp/glance";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "glance";
  };
}
