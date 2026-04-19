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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "weave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ydQ2ZhlCuXKpcYX3vqrHuD8GV2xY4jl3b4NOAqiQ3bo=";
  };

  cargoHash = "sha256-TFrOFndtOj3LWWfH26KzgNFa7mI9xEwRqUMZi+EFMHY=";

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
