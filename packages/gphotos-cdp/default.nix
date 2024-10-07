{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-10-06";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "b13473ade1138969ce96e1d0e4156191aaac2519";
    hash = "sha256-yWIT1xJh8SIK0UuYR5cp/y38uCApJJA6VvknhqEHIqo=";
  };

  vendorHash = "sha256-Uk9u1GEA0XIietbIwg4xCkrxG3VABM2B+DAzPJyPiHA=";

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
