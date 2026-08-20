{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.8.5-unstable-2026-08-19";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "a18cac8a84da9df2e87bfc45458810abba4a40fa";
    hash = "sha256-BVfkuBJASAcZyDnS+CzOktGH1i5CNmq9saATvun/BQo=";
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
