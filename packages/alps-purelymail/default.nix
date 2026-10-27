{
  fetchgit,
  alps,
}:
alps.overrideAttrs {
  version = "1-unstable-2026-10-27";

  src = fetchgit {
    url = "https://git.msfjarvis.dev/msfjarvis/alps";
    rev = "cea9881a82e2c03b6c0eb8d98661260bfa9cd24d";
    hash = "sha256-nJzG6p1lSTNTX/evLRknYOwf3IdVIQ4Isk7W8sGXsgk=";
  };

  vendorHash = "sha256-zVwfGBXoG03irlKnOcKDpaK2Z6fGEG8n1WRoFwwKhoA=";
}
