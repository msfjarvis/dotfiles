{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    # keep-sorted start
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
    "github.com/greenpau/caddy-security@v0.0.0-20261117011012-3225a2b42688"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20260826180304-de41b249af4f"
    "pkg.jsn.cam/caddy-defender@v0.0.0-20261122061647-5baad2613d10"
    # keep-sorted end
  ];
  hash = "sha256-32g1Rmh+GqiN9fQG80I4a1hKw/gxNZVO2hNVX1FgqRw=";
}
