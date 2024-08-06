{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.6.0-beta.1-unstable-2024-08-05";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "bf1cc475254fce79178198634dba496a91fd19d8";
    hash = "sha256-ySpH7jTBnCaAVLazxAvPDkUvtGB5j1R+4sKmxwwW264=";
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
