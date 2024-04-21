{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "yarr-dev";
  version = "unstable-2024-04-21";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = "yarr";
    rev = "4983e18e23b34126e778c2e56e684f9f8d801f2b";
    hash = "sha256-98rtTvDV/gmlbdBw94pVekqdMNILnCwcKwblFSWDbC8=";
  };

  vendorHash = null;

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Yet another rss reader";
    homepage = "https://github.com/nkanaev/yarr";
    license = licenses.mit;
    maintainers = with maintainers; [msfjarvis];
    mainProgram = "yarr";
  };
}
