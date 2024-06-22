{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.0.0";
in
buildGoModule {
  pname = "gphotos-cdp";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gphotos-cdp";
    rev = "4262092a2fe585f4b66bd50bd4c235e8f24824f6";
    hash = "sha256-xLCldbD37JEDQTwFSUqiEOM09vH+KaB/I8O3WoNqR6A=";
  };

  vendorHash = "sha256-FzGDVMKzAjISb4P7/vBIBTbBWpyAUnR26gXcvUWnjHw=";

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
