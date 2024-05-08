{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "nh";
  version = "unstable-2024-04-20";

  src = fetchFromGitHub {
    owner = "viperML";
    repo = "nh";
    rev = "6c772f572fd17ed9181625e221e2365e9bffc3f6";
    hash = "sha256-lLftlafVmv9RPzCO7gTsswiD+Q0MoAP0FVXVoK3iGmE=";
  };

  cargoHash = "sha256-cGrrv0fDD0H2tvUNyNK9u5Qyd6JUXCztDIPmcmtZ7w4=";

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  meta = with lib; {
    description = "Yet another nix cli helper";
    homepage = "https://github.com/viperML/nh";
    license = licenses.eupl12;
    mainProgram = "nh";
  };
}
