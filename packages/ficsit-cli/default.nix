{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "ficsit-cli";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = "ficsit-cli";
    rev = "v${version}";
    hash = "sha256-Zwidx0war3hos9NEmk9dEzPBgDGdUtWvZb7FIF5OZMA=";
  };

  vendorHash = "sha256-vmA3jvxOLRYj5BmvWMhSEnCTEoe8BLm8lpm2kruIEv4=";

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
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ficsit-cli";
  };
}
