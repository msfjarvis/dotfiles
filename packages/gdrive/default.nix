{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "gdrive";
  version = "3.0.13";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "gdrive";
    rev = "v${version}";
    hash = "sha256-FFNgMV3gPQ2p1ilYK+t10UgcNF/knO/PVM3Zw/VSSGw=";
  };

  vendorHash = "sha256-WibiLYMeWR63Q8lu287jeczT0n0/lh6T8PfOH7eJh8Q=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Google Drive CLI Client";
    homepage = "https://github.com/msfjarvis/gdrive";
    license = licenses.mit;
    maintainers = with maintainers; [ msfjarvis ];
    mainProgram = "gdrive";
  };
}
