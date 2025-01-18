{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.4-unstable-2025-01-17";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "ec9d455d181ee8f703e50e63079114074eb717b8";
    hash = "sha256-mEDuP/wIqNo3OZcTYT0RGH96tRQ1IQ1bhrF/2/fpxUA=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-6lYlfiUJpXANv9D7Ssc0yZ2iCz1VwrOzw8rhMo4HgkQ=";

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
