{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.4-unstable-2025-01-04";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "abbb4950a550a675624a7ac17b4aa61e9ea1a9dc";
    hash = "sha256-FEsZ+100i7Lh3YzRSQzdipSXfWdwUSPNmWrj8fuLffc=";
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
