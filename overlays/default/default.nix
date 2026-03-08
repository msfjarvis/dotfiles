{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  git-credential-manager = prev.git-credential-manager.overrideAttrs (_: {
    patches = [
      (prev.fetchpatch2 {
        # https://github.com/git-ecosystem/git-credential-manager/pull/1837
        url = "https://github.com/git-ecosystem/git-credential-manager/compare/main...d7e4f7673e6492634e70a93a7d8f84e055554b38.patch?full_index=1";
        hash = "sha256-qcoNTmGwoz7JntxgBBxF/OQ2he0Fc8AK2NSJHUhN+40=";
      })
    ];
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
