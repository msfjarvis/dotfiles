{
  buildGoModule,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  lib,
}:
let
  version = "0.22.0";
in
buildGoModule {
  pname = "piv-agent";
  inherit version;

  src = fetchFromGitHub {
    owner = "smlx";
    repo = "piv-agent";
    rev = "v${version}";
    hash = "sha256-bfJIrWDFQIg0n1RDadARPHhQwE6i7mAMxE5GPYo4WU8=";
  };

  buildInputs = [ pcsclite ];

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-HIB+p0yh7EWudLp1YGoClYbK3hkYEJZ+o+9BbOHE4+0=";

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
