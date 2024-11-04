{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-11-03";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "bacb607d902cd125c1e97d56d4b51ad56474cc54";
    hash = "sha256-LzrnbjljbJ8eCFsZwMp5ylx88IPSx5l3Vsy+2LeIFts=";
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
