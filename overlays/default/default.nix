{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };

  llm-agents =
    let
      llmPackages = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system};
    in
    {
      inherit (llmPackages) mcporter opencode skills;
      pi = llmPackages.pi.override { useBun = false; };
    };
}
