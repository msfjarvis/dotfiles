{ inputs, ... }:
_final: prev: {
  attic = inputs.attic.packages.${prev.system}.attic-client;
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk22;
  jdk_headless = prev.openjdk22_headless;
  jre = prev.openjdk22;
  jre_headless = prev.openjdk22_headless;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  pipeline = inputs.pipeline-app.packages.${prev.system}.default;
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
