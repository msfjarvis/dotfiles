{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.6.0-beta.2-unstable-2024-08-07";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "917e2cabfc8778ed4f1086e849ad7b5f609fec56";
    hash = "sha256-4ekxbfTKdZfxBobkJREzZoJQ7onDbaML5Bm1CW+MtwA=";
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
