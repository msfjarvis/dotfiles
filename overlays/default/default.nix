{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = (prev.qbittorrent.override { guiSupport = false; }).overrideAttrs (_: {
    patches = [
      (prev.fetchpatch2 {
        # https://github.com/qbittorrent/qBittorrent/pull/24286
        url = "https://patch-diff.githubusercontent.com/raw/qbittorrent/qBittorrent/pull/24286.patch";
        hash = "sha256-Lb/ly92RApsunqoAQaqHezWCmEyvxn6tTKJcX4IQrWw=";
      })
    ];
  });
}
