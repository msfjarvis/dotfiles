{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260322004838-772b4f647186"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260322005825-841f685a19d4"
    "github.com/greenpau/caddy-security@v0.0.0-20260319195732-75c22d926f36"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-JL1UtcJGDYcv+/SHAG6PlbWTCaj7PrX2wBkqIsquvx8=";
}
