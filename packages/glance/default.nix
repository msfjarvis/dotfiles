{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.5.1-unstable-2024-09-01";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "f76e06ec5707c72bc446d783e161512eafde22b0";
    hash = "sha256-z5W4EYC0M9Qo+sTpvw2A1vp5D/WdkoFl6QkFer4Vd1k=";
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
