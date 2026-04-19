{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260419005723-912d41769221"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260419010902-68a92634ccbd"
    "github.com/greenpau/caddy-security@v0.0.0-20260413124800-e17d199a4094"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-H1EqiJS5trZXYDvJ4thaWeAAUFmLVJHS3YR7XCH8drM=";
}
