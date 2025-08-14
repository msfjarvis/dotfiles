{
  lib,
  buildGo124Module,
  fetchFromGitHub,
}:
let
  version = "0.8.4-unstable-2025-08-11";
in
buildGo124Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "df9b886bd04ffad08244c08e3eeb59a66a6e28c0";
    hash = "sha256-ZJxPkU4aavXUHthdVRgmyqBCcY8rLz21ZL8GO0Am2mw=";
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
    maintainers = with maintainers; [ ];
    mainProgram = "glance";
  };
}
