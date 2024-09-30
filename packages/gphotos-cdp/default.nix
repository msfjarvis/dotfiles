{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-09-29";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "c59907012558000d0c99d9cbeb9a4b3f44e81d02";
    hash = "sha256-NFV0ntHe6XbNp5reBw4y15WmCL0I1PQ5QrsAnBuBz2M=";
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
