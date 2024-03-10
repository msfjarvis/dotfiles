_: _final: prev: {
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk21;
  jdk_headless = prev.openjdk21_headless;
  jre = prev.openjdk21;
  jre_headless = prev.openjdk21_headless;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [./megatools.patch];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override {
    fonts = ["JetBrainsMono"];
  };
  nix = prev.nixUnstable;
  qbittorrent = prev.qbittorrent.override {guiSupport = false;};
}
