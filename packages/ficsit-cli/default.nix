{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "ficsit-cli";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = "ficsit-cli";
    rev = "v${version}";
    hash = "sha256-eQbHGxxI7g543XlV5y1Np8QTUsfAJdbG9sPXKbUmluc=";
  };

  vendorHash = "sha256-3YqOwjCuXF48jsGjwv4mHMoGaiPDgxjzZTcrPAtA7I0=";

  ldflags = [
    "-s"
    "-w"
  ];

  # Tests try to access the live ficsit.app API
  doCheck = false;

  meta = {
    description = "A CLI tool for managing mods for the game Satisfactory";
    homepage = "https://github.com/satisfactorymodding/ficsit-cli";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "ficsit-cli";
  };
}
