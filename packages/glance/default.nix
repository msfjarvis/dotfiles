{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.8.5-unstable-2026-05-30";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "c8dc5bb453d5ebfd92ab9a61eaac512a73dfcc93";
    hash = "sha256-7VpSnT62i/wXNzczCXcYEQMr+zscHbB1zaxKx+E/bbg=";
  };

  patches = [
    ./0001-fix-lobsters-allow-excluding-tags.patch
  ];

  vendorHash = "sha256-a92V/duqvrWEb8QSJLA5rHYYZCcJ4fBC962SEr4FJDA=";

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
