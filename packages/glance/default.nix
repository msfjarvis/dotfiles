{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.3-unstable-2024-12-22";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "b4b61c94d7d75187b01e8d9d404cce53d56b4e29";
    hash = "sha256-C7GaaEwaMPkYqTzorN0x7JiVyG1CEnCOCosL+rbYgRc=";
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
