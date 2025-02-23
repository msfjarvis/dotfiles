{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  version = "3.0.7";
in
rustPlatform.buildRustPackage {
  pname = "healthchecks-monitor";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "healthchecks-monitor-v${version}";
    hash = "sha256-oUbGeEKEUAKtgOqB+LL/LYNjjDi6VKsGtu0KwQQKXzo=";
  };

  buildAndTestSubdir = "monitor";

  cargoHash = "sha256-va3/FcTlQjNgWr3w0zGzcoTMqE/gX0Wl09vRGB9vc/M=";
  useFetchCargoVendor = true;

  useNextest = true;

  meta = with lib; {
    description = "CLI tool to run shell jobs and report status to https://healthchecks.io";
    homepage = "https://msfjarvis.dev/g/healthchecks-rs";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "healthchecks-monitor";
  };
}
