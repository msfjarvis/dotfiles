{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260913042611-493dfa582bd4"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260522153743-9cc53305dea6"
    "github.com/greenpau/caddy-security@v0.0.0-20260919163713-2299ea5c751a"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
  ];
  hash = "sha256-kFBcZfu02xs0s7CtUcWf9HZrFSwTasu33SkR5cCbZxU=";
}
