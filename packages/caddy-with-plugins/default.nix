{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    # keep-sorted start
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
    "github.com/greenpau/caddy-security@v0.0.0-20260929092201-c93d1db14a2d"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20260826180304-de41b249af4f"
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260930063815-f32f8ea7f6ff"
    # keep-sorted end
  ];
  hash = "sha256-ko2jweN3pI17aSuIbMq0ieLQ74bZmJ2Ro/f2n/onU7E=";
}
