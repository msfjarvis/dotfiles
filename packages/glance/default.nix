{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-12-07";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "7f667e2d1cb6027fde8968e6c27da0cc9bfe7e12";
    hash = "sha256-Lkjdwxgl2XhHaodfHeXfUHqgx4aDLOnqe6LSrsIX05w=";
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
