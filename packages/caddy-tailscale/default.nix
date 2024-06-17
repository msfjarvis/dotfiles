{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "caddy-tailscale";
  version = "unstable-2024-06-07";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "caddy-tailscale";
    rev = "5cc2140a0eb3b884de161e26d37cc4098de91d57";
    hash = "sha256-2dakUsmwVNTDcMKohSp+5G/C5rDpls5FYXUWvF46chs=";
  };

  vendorHash = "sha256-m0R8DwI83Pr0cMV6DWK7QTgwKjrEd7Wsf00DOYmczbs=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/caddy" ];

  meta = with lib; {
    description = "A highly experimental exploration of integrating Tailscale and Caddy";
    homepage = "https://github.com/tailscale/caddy-tailscale";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "caddy-tailscale";
  };
}
