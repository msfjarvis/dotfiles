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
        url = "https://github.com/Mic92/nix-update/commit/26a2459088658c8e395c67f18a232ee3ce9e2dc0.patch?full_index=1";
        hash = "sha256-bXAEJq8WsZm+fl1jTeBXNH+je+wpWzXG7OkTOT/mgew=";
      })
    ];
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
