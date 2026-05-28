{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
}
