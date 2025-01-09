{ inputs, ... }:
final: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Force the use of the JDK we're using everywhere else
  jdk = prev.openjdk23;
  jdk_headless = prev.openjdk23_headless;
  jre = prev.openjdk23;
  jre_headless = prev.openjdk23_headless;
  lix = inputs.lix.packages.${prev.stdenv.hostPlatform.system}.default;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  nix-update = (prev.nix-update.override { nix = final.lix; }).overrideAttrs (_: {
    patches = [
      # https://github.com/Mic92/nix-update/pull/317
      (prev.fetchpatch2 {
        url = "https://github.com/Mic92/nix-update/commit/8e9c62b7649ef5b0c1d8522ba9e7ffc4aa248ba4.patch?full_index=1";
        hash = "sha256-NtOGL5DexeCKYqUZid+EEEm3q28yVsE6qcJztgU0nsI=";
      })
    ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
