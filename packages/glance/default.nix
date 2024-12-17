{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.3-unstable-2024-12-16";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "dbcc13a5cf92813eb9ff444888341f0fbaba568e";
    hash = "sha256-hCn/JChWBP89Ip7OiABsosmepGYCad4ehJibiLb2kK8=";
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
