{
  rust,
  stdenv,
  fetchurl,
}:
let
  arch = stdenv.hostPlatform.rust.rustcTarget;
  fetch_librusty_v8 =
    args:
    fetchurl {
      name = "librusty_v8-${args.version}";
      url = "https://github.com/denoland/rusty_v8/releases/download/v${args.version}/librusty_v8_release_${arch}.a.gz";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      meta = {
        inherit (args) version;
      };
    };
in
fetch_librusty_v8 {
  version = "0.89.0";
  shas = {
    x86_64-linux = "sha256-XxX3x3LBiJK768gvzIsV7aKm6Yn5dLS3LINdDOUjDGU=";
    aarch64-linux = "sha256-ZetNxahe/XDp6OoGFkZS7VfOPQPbEGUkPNAaSJ0Y90M=";
    x86_64-darwin = "sha256-A047aVL2KSNWofPK2eH395iGPcdM+FjSxu5GkW9wJnI=";
    aarch64-darwin = "sha256-XN2JFL8Rs9hyTquVx6brjW15H54mhVIHqzkdEy9smqM=";
  };
}
