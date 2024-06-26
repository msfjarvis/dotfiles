{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "caddy-tailscale";
  version = "0-unstable-2024-06-20";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "caddy-tailscale";
    rev = "082211afbda14720331f5a6ba94030e79bb8e1e5";
    hash = "sha256-/HoHN9/F25rKUUudeYvwSCR3X4U81xjQvInWb3kjqbU=";
  };

  vendorHash = "sha256-8TFJn9VMoQhvxmPzsTI1RXyxUvj2kfiYEdkv5aflhjw=";

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
