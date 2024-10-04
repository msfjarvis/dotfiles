{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0-unstable-2024-10-04";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "a44310ee224badb956cfa325bb1282737b03f7ca";
    hash = "sha256-lKav6d6UxVpBoYlBF8pSs57qiwFfhHRpmEsTZcPqP54=";
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
