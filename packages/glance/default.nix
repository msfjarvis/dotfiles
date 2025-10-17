{
  lib,
  buildGo124Module,
  fetchFromGitHub,
}:
let
  version = "0.8.4-unstable-2025-10-16";
in
buildGo124Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "49058b0300f96bc2c4c6318b5656f0d42df56bbd";
    hash = "sha256-9R8HxxqW+mmmy12H+VSMlEi9M8dQy/F6+oU2xtrd9K4=";
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
