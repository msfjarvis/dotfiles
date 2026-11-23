{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.8.8-unstable-2026-11-07";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "53aec7f392ca72143870dcb45526ec7c80a68f32";
    hash = "sha256-b/FTXk0ZKvCZvJ0F4cJiJ5uByQTShY6MrB3EmdipCow=";
  };

  patches = [
    ./0001-fix-lobsters-allow-excluding-tags.patch
  ];

  vendorHash = "sha256-btFhC33IwzldCtPi9lqGz7tNG6wqujjIlp11Iqi24qk=";

  excludedPackages = [ "build-and-ship" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A self-hosted dashboard that puts all your feeds in one place";
    homepage = "https://github.com/glanceapp/glance";
    license = licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "glance";
  };
}
