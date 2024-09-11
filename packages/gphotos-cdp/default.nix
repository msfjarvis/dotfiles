{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-09-08";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "8c460b6a31ecde5646e5b551022b694a6d6e70d0";
    hash = "sha256-KS7z5VWvYfGlrI/Mx+ZVLovI2EibS3mLzPEn6naJATs=";
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
