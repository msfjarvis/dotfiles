{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-09-01";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "8035ce4c148a76c2a5f1f12f188431fd8b35635c";
    hash = "sha256-nLUguLWCiEDLK8s+ctWw8L/4ZXiveMK1873xCo5Wy90=";
  };

  vendorHash = "sha256-AJjCfKA98v5oci/yCmrsQCLAIg3E9C1aKV3g4y6L3xI=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "This program uses the Chrome DevTools Protocol to drive a Chrome session that downloads your photos stored in Google Photos";
    homepage = "https://github.com/msfjarvis/gphotos-cdp";
    license = licenses.asl20;
    mainProgram = "gphotos-cdp";
  };
}
