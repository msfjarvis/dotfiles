{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "miniflux";
  version = "2.1.3-unstable-2024-07-04";

  src = fetchFromGitHub {
    owner = "miniflux";
    repo = "v2";
    rev = "a60996e666598ba5e2e8951d33093fbdb7ccafe8";
    hash = "sha256-uwM0zABnvRnKiz6OwtSb5s7+W5FTu9AR1JMT0j+OfFg=";
  };

  vendorHash = "sha256-aMehKJE8evBLVB/SIjHBxNB/xA/8XQPbDxOW5q2ffu8=";

  nativeBuildInputs = [ installShellFiles ];

  checkFlags = [ "-skip=TestClient" ]; # skip client tests as they require network access

  ldflags = [
    "-s"
    "-w"
    "-X miniflux.app/v2/internal/version.Version=${version}"
  ];

  postInstall = ''
    mv $out/bin/miniflux.app $out/bin/miniflux
    installManPage miniflux.1
  '';

  meta = with lib; {
    description = "Minimalist and opinionated feed reader";
    homepage = "https://miniflux.app/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "miniflux";
  };
}
