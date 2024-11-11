{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "age-keygen-deterministic";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "keisentraut";
    repo = "age-keygen-deterministic";
    rev = "v${version}";
    hash = "sha256-zD0v+0uqGX3KSN65bKzUrsu9QZX+B7qiTqzfpGZfIUo=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Simple Rust CLI tool to derive an age private key from passphrase";
    homepage = "https://github.com/keisentraut/age-keygen-deterministic";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "age-keygen-deterministic";
  };
}
