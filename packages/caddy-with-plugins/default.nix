{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260308024645-002ffba5d154"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260308005612-657a6982f08f"
    "github.com/greenpau/caddy-security@v0.0.0-20260313012515-2b0bb0fd8663"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-FVmTl2BgY86PqzaMVcuXrDKfwHQWY0X00W6Xn+rq/YM=";
}
