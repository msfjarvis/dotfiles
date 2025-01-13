{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:
let
  version = "0.6.4-unstable-2025-01-12";
in
buildGo123Module {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "5723fbdea566e13978920d88cc99842a4a20c608";
    hash = "sha256-kThJPfhtTC1wm5c54cE3AMY7VgXcFc+jDm02nJUOxeo=";
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
