{
  darwin,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "adx";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "adx";
    rev = "v${version}";
    hash = "sha256-oE7LHZdIoDPRzhbJoiMPwQvIwKmNm4mZa7X19j5qybg=";
  };

  cargoHash = "sha256-N4w6iWgTc6Q+QnuWtz4Y/qmBNZ9GqxrdwMWNgbuAEgY=";

  # Tests are annoying to make work with buildRustPackage
  doCheck = false;

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = with lib; {
    description = "Rust tooling to poll Google Maven repository for updates to AndroidX artifacts";
    homepage = "https://github.com/msfjarvis/adx";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "adx";
  };
}
