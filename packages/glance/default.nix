{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
let
  version = "0.5.0";
in
buildGoModule {
  pname = "glance";
  inherit version;

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "glance";
    rev = "v${version}";
    hash = "sha256-37DmLZ8ESJwB2R8o5WjeypKsCQwarF3x8UYz1OQT/tM=";
  };

  patches = [ ./auto-update.patch ];

  vendorHash = "sha256-Okme73vLc3Pe9+rNlmG8Bj1msKaVb5PaIBsAAeTer6s=";

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
