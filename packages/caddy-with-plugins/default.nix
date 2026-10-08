{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    # keep-sorted start
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
    "github.com/greenpau/caddy-security@v0.0.0-20261005163436-a48553d04002"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20260826180304-de41b249af4f"
    "pkg.jsn.cam/caddy-defender@v0.0.0-20261004053024-85272705fb05"
    # keep-sorted end
  ];
  hash = "sha256-eVH7Or6Z1jC9yz4wKC+CaFJL5EHcP2VflW/Z8DJk/Ck=";
}
