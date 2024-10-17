{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-10-16";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "18bb2d7501dca4f887479c634579df92abd57cbd";
    hash = "sha256-gZjwo5fxPaNn2tDusm5zU55IjnO3mmR3FQgwEEG/OAM=";
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
