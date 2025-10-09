{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250928020225-c085b0ec8e68"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250829143804-5041083e02a1"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20250723144432-4e8672b140b0"
    "github.com/greenpau/caddy-security@v0.0.0-20250325161856-83609dec14a4"
  ];
  hash = "sha256-tliLAmov4V/w1NoDHUHxRBL08RhNNd/atIkKnanbEKQ=";
}
