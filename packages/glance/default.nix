{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-10-21";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "6e5140d859bf3a632edcf0f0607f4da8238ea772";
    hash = "sha256-hnIGTZ1CwXtpLxrcMCAYwVv1R9FFFDYyXjvwUVlAKM0=";
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
