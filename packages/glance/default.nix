{
  lib,
  buildGo124Module,
  fetchFromGitHub,
}:
let
  version = "0.8.4-unstable-2025-09-06";
in
buildGo124Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "b3b86b34838cf105c594709341c3be343b14cb93";
    hash = "sha256-UaqZIbnLjNLsBLV+fCaNpAsYX5WIAsQqP/QkAZ2e0mY=";
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
