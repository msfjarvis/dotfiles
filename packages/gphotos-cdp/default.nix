{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-09-22";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "d83605af150a8737c630dd13e80098add0b422f6";
    hash = "sha256-KZPc1CXSAnW0zD8ug0WMFSpm2pTPLxlRssqMtvNiG10=";
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
