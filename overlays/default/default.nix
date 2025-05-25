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
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk23;
  jdk_headless = prev.openjdk23_headless;
  jre = prev.openjdk23;
  jre_headless = prev.openjdk23_headless;
  lix = inputs.lix.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (_: {
    doCheck = !prev.stdenv.isDarwin;
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
  utillinux = prev.util-linux;
}
