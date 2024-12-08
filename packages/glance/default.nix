{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-12-08";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "d4b1d240b9dc1bcf735e2582cec9383e795f0dfe";
    hash = "sha256-lGNsRifyStUL6Xo5/C9X5FNWkRLZ3N7z25KQQ7REkAI=";
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
