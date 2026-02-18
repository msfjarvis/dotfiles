{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule rec {
  pname = "caldav-api";
  version = "0-unstable-2026-02-18";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes.git";
    rev = "730b121c215a6fee66f276190d09c8f54f5f2e60";
    hash = "sha256-sAaJl28i56fSf34oqekJSS9kf9MferdKGzUeT+UyN/w=";
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
