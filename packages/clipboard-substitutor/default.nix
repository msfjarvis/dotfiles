{
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  xorg,
  lib,
}:
let
  version = "0.7.8";
in
rustPlatform.buildRustPackage {
  pname = "clipboard-substitutor";
  inherit version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "clipboard-substitutor";
    rev = "v${version}";
    hash = "sha256-em3Zwr0rg53I7HACn8souLzr3Bd+iSoR5rKvxwYTDEI=";
  };

  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "journald" ];
  cargoHash = "sha256-ePyfXZ0XEUf0oc3yhW+A71HpwaBnHY2cklIR/RL05BA=";

  useNextest = true;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ xorg.libxcb ];

  meta = with lib; {
    description = "CLI to listen to clipboard events and perform operations on the copied text";
    homepage = "https://github.com/msfjarvis/clipboard-substitutor";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "clipboard-substitutor";
  };
}
