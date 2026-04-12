{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260412005524-175ea05eda28"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260412010641-2a505adaed32"
    "github.com/greenpau/caddy-security@v0.0.0-20260403154904-fb799584502f"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-GBrwx3bKm+1cMmYp9W/Hs/Hqy+a6krbTRYgyCdtu+rw=";
}
