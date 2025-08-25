{
  lib,
  buildGo124Module,
  fetchFromGitHub,
}:
let
  version = "0.8.4-unstable-2025-08-17";
in
buildGo124Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "e3f69864ac8bfaa74b83e3e65507ee60add002bc";
    hash = "sha256-IIElxGpryafFn0OlDRss7WeUbeJUxx8sJaMQhDJEJTA=";
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
