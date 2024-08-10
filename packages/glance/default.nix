{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.5.1-unstable-2024-08-09";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "b25b1177172522c2f9c7f004589aa447c55063ea";
    hash = "sha256-Xi+ThI3nvtX4m4rd5bH/QfE2gFjx7JxVgfaEi4tqsG8=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-BLWaYiWcLX+/DW7Zzp6/Mtw5uVxIVtfubB895hrZ+08=";

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
