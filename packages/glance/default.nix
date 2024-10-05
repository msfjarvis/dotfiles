{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-10-04";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "c41cfadb19d2cf274b8a17c441d439c885f3f81a";
    hash = "sha256-Obe2PVXLIK6lGs7DSMSI0fb3qnbKKUf+h4A+oi6szho=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-++MbothZxWIer/r24r10Q5bpuOf2bTgPB36/BvdI98s=";

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
