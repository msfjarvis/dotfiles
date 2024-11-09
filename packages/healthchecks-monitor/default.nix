{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
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

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  buildAndTestSubdir = "monitor";

  cargoHash = "sha256-9sZfCna4jSEJ2z4xtlk+YHN2MHC2IGf0Zzyw96MMhnI=";

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
