{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.6.0-beta.1-unstable-2024-08-04";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "af975d0e7f9a244c3cadea9fe604c60467f2f8ab";
    hash = "sha256-3ls0BmSLnZo9/z3bIJaDReGaChJc9HiHklOX6XAX7NI=";
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
