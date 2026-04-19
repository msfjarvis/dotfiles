{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "weave";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "weave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A9beYK1i52ghb4QQJLp5hw1DeIIc1AiK72oW5D3u08E=";
  };

  cargoHash = "sha256-C7vJQZ15TE9XwVLi1uCjYdQPr3TDPVEQfOVENeKXg14=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = {
    description = "Entity-level semantic merge driver for Git. Resolves conflicts that git can't by understanding code structure via tree-sitter. 31/31 clean merges vs git's 15/31";
    homepage = "https://github.com/Ataraxy-Labs/weave";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "weave";
  };
})
