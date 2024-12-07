{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-12-06";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "e3bdc730134ae47f51715cb26ca136aa06ab2012";
    hash = "sha256-OalXApVsFP3NHT6POuEfatF1kkFBHYm7b8zTIi4xJ/w=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-sgAt6ct8xvQNZRa/UFQWEsFN9N7MJ0Pe3CckOLlrvdc=";

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
