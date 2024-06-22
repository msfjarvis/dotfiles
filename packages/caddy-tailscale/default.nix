{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "caddy-tailscale";
  version = "0-unstable-2024-06-18";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "caddy-tailscale";
    rev = "4e8fde6df984ff16921cbd9ce68263b4e99889c7";
    hash = "sha256-lq/PU3R6FRigazo34OiW3vx22RkXCYPHdj0D614MGxY=";
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
