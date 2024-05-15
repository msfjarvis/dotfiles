{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "nh";
  version = "3.5.15";

  src = fetchFromGitHub {
    owner = "viperML";
    repo = "nh";
    rev = "6c772f572fd17ed9181625e221e2365e9bffc3f6";
    hash = "sha256-lLftlafVmv9RPzCO7gTsswiD+Q0MoAP0FVXVoK3iGmE=";
  };

  cargoHash = "sha256-IW+fzWvLv1/5Z/73EZreVLMw/JElvs+HOnuU8RV7w8w=";

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  meta = with lib; {
    description = "Yet another nix cli helper";
    homepage = "https://github.com/viperML/nh";
    license = licenses.eupl12;
    mainProgram = "nh";
  };
}
