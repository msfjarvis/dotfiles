{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-10-02";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "8a8aaa752e5dc5ad2d1a478c0267dfab9732122b";
    hash = "sha256-DYD4xMYIbmIcMUf9107c7agn/npZCm+e+MEmVnoX2xI=";
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
