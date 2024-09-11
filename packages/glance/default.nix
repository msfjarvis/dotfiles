{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.6.1-unstable-2024-09-08";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "d60457afaf6fe88dbed82ea04c765f9c24789644";
    hash = "sha256-0P1f7IDEPSlVHtrygIsD502lIHqLISsSAi9pqB/gFdA=";
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
