{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.4-unstable-2024-12-28";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "ac7f3805d47cf9d5b4d1b28495226034b50b1e8b";
    hash = "sha256-hptbOEfRjcWAwjCIPwc4rOBS1XeVeZkZL8sfos3JNkk=";
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
