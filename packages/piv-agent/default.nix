{
  buildGoModule,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  lib,
}:
let
  version = "0.23.0";
in
buildGoModule {
  pname = "piv-agent";
  inherit version;

  src = fetchFromGitHub {
    owner = "smlx";
    repo = "piv-agent";
    rev = "v${version}";
    hash = "sha256-4oyIUE7Yy0KUw5pC64MRKeUziy+tqvl/zFVySffxfBs=";
  };

  buildInputs = [ pcsclite ];

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-4yfQQxMf00263OKEXTWD34YifK7oDclvPk8JDz5N1I0=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "An SSH and GPG agent which you can use with your PIV hardware security device (e.g. a Yubikey";
    homepage = "https://github.com/smlx/piv-agent";
    license = licenses.asl20;
    mainProgram = "piv-agent";
  };
}
