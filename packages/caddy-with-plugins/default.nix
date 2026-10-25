{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    # keep-sorted start
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
    "github.com/greenpau/caddy-security@v0.0.0-20261023222939-15d5f6b01853"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20260826180304-de41b249af4f"
    "pkg.jsn.cam/caddy-defender@v0.0.0-20261025041719-c75c981ac347"
    # keep-sorted end
  ];
  hash = "sha256-TQiwiRGjj/+GSfR2aZNoCU0wd8m9H7pwE3FmDo7utlU=";
}
