{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule rec {
  pname = "caldav-api";
  version = "0-unstable-2026-02-19";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes.git";
    rev = "e813f57303e9c2efe0097e4b4140a1ed2dc74297";
    hash = "sha256-I5Wf2qmP/ygZDkm+f7BTL/6wpSRCGRFGjELMmlfQ+P0=";
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
