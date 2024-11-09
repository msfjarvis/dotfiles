{
  darwin,
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
  cargoHash = "sha256-5jKZcH+B6KhBeFpXH6Ce4iNkXSol8Iwnp0JB4p9LcLM=";

  useNextest = true;

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [ darwin.apple_sdk.frameworks.AppKit ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ xorg.libxcb ];

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
