{
  buildGoModule,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  lib,
}:
let
  version = "0.23.1";
in
buildGoModule {
  pname = "piv-agent";
  inherit version;

  src = fetchFromGitHub {
    owner = "smlx";
    repo = "piv-agent";
    rev = "v${version}";
    hash = "sha256-NNgDkdsEN2LxgxTlH4rMkod2E0/BDkjcS8Pes2/ZFEs=";
  };

  buildInputs = [ pcsclite ];

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-k1PMHUGu3I8tLFeeHjV2ZO9R/sHbbPzNa5u/HxzdlYc=";

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
