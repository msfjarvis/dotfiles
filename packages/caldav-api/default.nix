{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule rec {
  pname = "caldav-api";
  version = "0-unstable-2026-03-26";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes.git";
    rev = "f4d87fdd21ee3740b3564fe47a2b3e8caab5fe5e";
    hash = "sha256-cLagoyHYR2J0j5Glz4g6gKX1nQ3jQZwIHSFKRTbmQ3I=";
  };

  sourceRoot = "${src.name}/caldav-api";

  vendorHash = "sha256-kKJrb1MIXTzfzvkgLCis18UTGSjZSMz1K6dVTF7V76Y=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "HTTP API for CalDAV operations";
    homepage = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "caldav-api";
  };
}
