{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.1";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "782fb3b1907a10ca4ccc4f55bb800a30843d6dde";
    hash = "sha256-6J/OWvL/cC7qE+q40dnyqfBP42mUAXIesF0VmOJsEUo=";
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
