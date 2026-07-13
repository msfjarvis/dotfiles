{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };

  llm-agents = {
    inherit (inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system}) pi opencode;
  };
}
