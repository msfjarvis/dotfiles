{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260628011425-b043f6543a80"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260522153743-9cc53305dea6"
    "github.com/greenpau/caddy-security@v0.0.0-20260425125447-e03784fa0581"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
  ];
  hash = "sha256-bjsMx1qpv5YUNqYv7TaRMRo6VMW/z2FNFhEVNk585yU=";
}
