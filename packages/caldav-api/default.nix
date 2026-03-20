{
  lib,
  buildGoModule,
  fetchgit,
}:
buildGoModule rec {
  pname = "caldav-api";
  version = "0-unstable-2026-03-21";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/acceptable-vibes.git";
    rev = "8dbf677cf6721febd53a71c5c39b69b6767d8bb2";
    hash = "sha256-btg2QUyXXUCgR1LgE86i73rBh07WxzINxll3i8eDwFI=";
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
