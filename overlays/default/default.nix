{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  calibre-web = prev.calibre-web.overrideAttrs (old: {
    pythonRelaxDeps = old.pythonRelaxDeps ++ [ "requests" ];
  });
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
    # This no longer applies and I also don't care to use OpenCode at this point.
    # patches = [ ./opencode-pr-22062.patch ];
  });
  qbittorrent = (prev.qbittorrent.override { guiSupport = false; }).overrideAttrs (_: {
    patches = [
      (prev.fetchpatch2 {
        # https://github.com/qbittorrent/qBittorrent/pull/24286
        url = "https://patch-diff.githubusercontent.com/raw/qbittorrent/qBittorrent/pull/24286.patch";
        hash = "sha256-61uh5gVcuUkuZoiYqSSw9w8FrBTmAyW5EPexmYNaezY=";
      })
    ];
  });
}
