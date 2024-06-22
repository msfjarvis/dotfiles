{
  darwin,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
let
  version = "2.0.8";
in
rustPlatform.buildRustPackage {
  pname = "hcctl";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "healthchecks-rs";
    rev = "hcctl-v${version}";
    hash = "sha256-A83pzY+c4kz59tHEc6hRd0Zp8Uj96KdrenD9RDWwavQ=";
  };

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  buildAndTestSubdir = "hcctl";

  cargoHash = "sha256-v8mpH1akao35P8ePFTFLBidkPW+vzsaMg4h51TudYMM=";

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
