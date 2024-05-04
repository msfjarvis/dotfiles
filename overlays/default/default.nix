{inputs, ...}: _final: prev: {
  attic = inputs.attic.packages.${prev.system}.attic-client;
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk22;
  jdk_headless = prev.openjdk22_headless;
  jre = prev.openjdk22;
  jre_headless = prev.openjdk22_headless;
  logseq = prev.logseq.overrideAttrs (old: {
    # Remove NIXOS_OZONE_WL compat which breaks the app entirely
    postFixup = ''
      makeWrapper ${prev.electron_27}/bin/electron $out/bin/${old.pname} \
        --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
        --add-flags $out/share/${old.pname}/resources/app
    '';
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [./megatools.patch];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override {
    fonts = ["JetBrainsMono"];
  };
  nix = prev.nixVersions.git;
  qbittorrent = prev.qbittorrent.override {guiSupport = false;};
}
