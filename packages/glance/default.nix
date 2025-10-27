{
  lib,
  buildGo124Module,
  fetchFromGitHub,
}:
let
  version = "0.8.4-unstable-2025-10-26";
in
buildGo124Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "784bf5342570af94e62238c4f4a7b542d1853077";
    hash = "sha256-vXdKSz89kSOb/gIwcq+vpRSYoHnKCWjQNodzLwsl/vs=";
  };

  vendorHash = "sha256-g5ZZneJ1g5rs3PJcNP+bi+SuRyZIXBPBjWiKt7wbe5I=";

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
