{ inputs, ... }:
_: prev: {
  inherit (inputs.firefox.packages.${prev.stdenv.hostPlatform.system}) firefox-nightly-bin;
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [ ./megatools.patch ];
  });
  # rsync 3.4.3 is going through an infinite regression simulator thanks to Claude
  rsync = prev.rsync.overrideAttrs(_: rec {
  	version = "3.4.1";

  	src = prev.fetchurl {
  	  # signed with key 9FEF 112D CE19 A0DC 7E88  2CB8 1BB2 4997 A853 5F6F
  	  url = "mirror://samba/rsync/src/rsync-${version}.tar.gz";
  	  hash = "sha256-KSS8s6Hti1UfwQH3QLnw/gogKxFQJ2R89phQ1l/YjFI=";
  	};
  });
  qbittorrent = prev.qbittorrent.override { guiSupport = false; };
}
