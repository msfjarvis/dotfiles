{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "2.0.9";
in
rustPlatform.buildRustPackage {
  pname = "hcctl";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "hcctl-v${version}";
    hash = "sha256-oUbGeEKEUAKtgOqB+LL/LYNjjDi6VKsGtu0KwQQKXzo=";
  };

  buildAndTestSubdir = "hcctl";

  cargoHash = "sha256-va3/FcTlQjNgWr3w0zGzcoTMqE/gX0Wl09vRGB9vc/M=";
  useFetchCargoVendor = true;

  useNextest = true;

  meta = with lib; {
    description = "Simple CLI tool to keep a track of your https://healthchecks.io account";
    homepage = "https://msfjarvis.dev/g/healthchecks-rs";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "hcctl";
  };
}
