{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  git-credential-manager = prev.git-credential-manager.overrideAttrs (_: {
    patches = [
      (prev.fetchpatch2 {
        # https://github.com/git-ecosystem/git-credential-manager/pull/1837
        url = "https://github.com/git-ecosystem/git-credential-manager/compare/main...db20a7bbb558dc73be6f5bfa5c0a805223a3e1e4.patch?full_index=1";
        hash = "sha256-3uuDAvgUdFNxbwuZAsWCqOvoLUnNZcajSkWHl07IjSE=";
      })
    ];
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  # Patch GitHub Copilot premium request overuse
  opencode = prev.opencode.overrideAttrs (_: {
    patches = [ ./opencode-pr-22062.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
