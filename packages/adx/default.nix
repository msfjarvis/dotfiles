{
  pkgs,
  lib,
}: let
  inherit (pkgs) darwin fetchFromGitHub rustPlatform stdenv;
in
  rustPlatform.buildRustPackage rec {
    pname = "adx";
    version = "4.5.3";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "adx";
      rev = "v${version}";
      hash = "sha256-u+vUt3ACfj+V1MPVb4whI2b7h4IFdEWHxLnuwiGMQ/8=";
    };

    cargoHash = "sha256-4RHJqo9pNnLbaV6RvpGydmTb3EEvzsVh1ThZ1NM5V1E=";

    useNextest = true;
    # Needed for tests to pass
    RUSTFLAGS = "--cfg nix_check";

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

    meta = with lib; {
      description = "Rust tooling to poll Google Maven repository for updates to AndroidX artifacts";
      homepage = "https://github.com/msfjarvis/adx";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "adx";
    };
  }
