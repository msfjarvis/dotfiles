{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.3-unstable-2024-12-17";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "ab6ae15836d18b8950ec07dc3ad5e4e5ee04274c";
    hash = "sha256-I9/Vr2hRPET3nzI0xFac62DZNXP5tVgSN/QV6qDq/Co=";
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
