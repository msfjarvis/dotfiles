{
  darwin,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  xorg,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "clipboard-substitutor";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "clipboard-substitutor";
    rev = "v${version}";
    hash = "sha256-WSvSDZJ2SOtE68BHv7IINieVgblfWdpNrurFH7+83aI=";
  };

  buildFeatures = lib.optionals stdenv.isLinux ["journald"];
  cargoHash = "sha256-iYSR7dXrEU0VasCzmkA0lSW6Wj5t8o3uF4oVIc8chy8=";

  useNextest = true;

  buildInputs =
    lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
    ]
    ++ lib.optionals stdenv.isLinux [
      xorg.libxcb
    ];

  meta = with lib; {
    description = "CLI to listen to clipboard events and perform operations on the copied text";
    homepage = "https://github.com/msfjarvis/clipboard-substitutor";
    license = with licenses; [asl20 mit];
    maintainers = with maintainers; [msfjarvis];
    mainProgram = "clipboard-substitutor";
  };
}
