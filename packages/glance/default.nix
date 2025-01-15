{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.4-unstable-2025-01-14";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "a7e235441b3630e418f2498372bd2539b662ee1e";
    hash = "sha256-JgzPLOkLq5Lndtr+6QgFnQkxPdsJf1fmRwwj0ijUoZs=";
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
