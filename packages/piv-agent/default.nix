{
  buildGoModule,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  lib,
}:
let
  version = "0.21.2";
in
buildGoModule {
  pname = "piv-agent";
  inherit version;

  src = fetchFromGitHub {
    owner = "smlx";
    repo = "piv-agent";
    rev = "v${version}";
    hash = "sha256-nHxtQaQ5Lc0QAJrWU6fUWViDwOKkxVyj9/B6XZ+Y0zw=";
  };

  buildInputs = [ pcsclite ];

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-L5HuTYA01w3LUtSy7OVxG6QN5uQZ8LVYyrBcJQTkIUA=";

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
