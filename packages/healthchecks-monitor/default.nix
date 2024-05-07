{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "healthchecks-monitor";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "healthchecks-monitor-v${version}";
    hash = "sha256-A83pzY+c4kz59tHEc6hRd0Zp8Uj96KdrenD9RDWwavQ=";
  };

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  buildAndTestSubdir = "monitor";

  cargoHash = "sha256-2+dV0mIvbDqXqRfNCBhqUVRYhpcPB2oxD67GBkEDW48=";

  useNextest = true;

  meta = with lib; {
    description = "CLI tool to run shell jobs and report status to https://healthchecks.io";
    homepage = "https://msfjarvis.dev/g/healthchecks-rs";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ msfjarvis ];
    mainProgram = "healthchecks-monitor";
  };
}
