{
  pkgs,
  lib,
}: let
  inherit (pkgs) buildGoModule fetchFromGitHub pcsclite pkg-config;
in
  buildGoModule rec {
    pname = "piv-agent";
    version = "0.21.0";

    src = fetchFromGitHub {
      owner = "smlx";
      repo = "piv-agent";
      rev = "v${version}";
      hash = "sha256-aukcnubhB8kbAl22eeFKzLPvVcYdgcEQ1gy3n6KWG00=";
    };

    buildInputs = [pcsclite];

    nativeBuildInputs = [pkg-config];

    vendorHash = "sha256-1d6EKEvo4XNDXRtbdnKkqyF9y0LPPHWKu9X/wYnbmas=";

    ldflags = ["-s" "-w"];

    meta = with lib; {
      description = "An SSH and GPG agent which you can use with your PIV hardware security device (e.g. a Yubikey";
      homepage = "https://github.com/smlx/piv-agent";
      license = licenses.asl20;
      maintainers = with maintainers; [];
      mainProgram = "piv-agent";
    };
  }
