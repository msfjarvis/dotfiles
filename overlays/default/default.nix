{ inputs, ... }:
_final: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  inherit (inputs.ghostty.packages.${prev.stdenv.hostPlatform.system}) ghostty;
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk23;
  jdk_headless = prev.openjdk23_headless;
  jre = prev.openjdk23;
  jre_headless = prev.openjdk23_headless;
  lix = inputs.lix.packages.${prev.stdenv.hostPlatform.system}.default;
  logseq = prev.logseq.overrideAttrs (old: {
    # Remove NIXOS_OZONE_WL compat which breaks the app entirely
    postFixup = ''
      makeWrapper ${prev.lib.getExe prev.electron_27} $out/bin/${old.pname} \
        --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
        --add-flags $out/share/${old.pname}/resources/app
    '';
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
  vesktop = prev.vesktop.overrideAttrs (_old: {
    # Remove NIXOS_OZONE_WL compat which breaks the app entirely
    postFixup = ''
      makeWrapper ${prev.electron}/bin/electron $out/bin/vesktop \
        --add-flags $out/opt/Vesktop/resources/app.asar
    '';
  });
}
