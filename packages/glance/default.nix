{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.2-unstable-2024-11-24";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "2b0dd3ab995c595d351492e0bfb7dd8ee22b4c43";
    hash = "sha256-+TP/tqgwMKgQOjJJco+GJMdEyz1+MPJmr7LgMdmvoys=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-yUtF2JG9YIfYSiuzf6z2fKaDT/K6Y9j0OrM3/QLlUG8=";

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
