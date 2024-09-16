{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-09-15";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "88acf4ab5cd92cfca292385dd8d67e0bea10fa2c";
    hash = "sha256-3n39JT8NtQRKulFOi5SCgBX2L7ApZtTvB9zrX1iTxsc=";
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
