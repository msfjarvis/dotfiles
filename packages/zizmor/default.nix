{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "zizmor";
  version = "1.0.0-unstable-2025-01-03";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = "zizmor";
    rev = "3f44a170d3cab80919eb83ce80aefcecfde799d7";
    hash = "sha256-mewoVXwOWv2FtFICXKhObboPHw6ObvxOKV2uu9c76f4=";
  };

  cargoHash = "sha256-XevLhQ6yhZVDK3HLFV5JVp1R10g+6njYO76snCGnxtc=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = {
    description = "A static analysis tool for GitHub Actions";
    homepage = "https://github.com/woodruffw/zizmor";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "zizmor";
  };
}
