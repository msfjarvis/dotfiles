{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule rec {
  pname = "caldav-api";
  version = "0-unstable-2026-03-04";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes.git";
    rev = "635d0e183654fa8b76cebf7aa352287ce0ee7102";
    hash = "sha256-pL/Wq7DNUz9rrQtLi/OTBvCBH1qxVvEzDsnJUvF0kkM=";
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
