{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260315005141-bad89cc054bb"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260315010250-c631cf5fbf9f"
    "github.com/greenpau/caddy-security@v0.0.0-20260315002256-b8134e152290"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-k/fFxbaEIF/4abzbRlO2AIexYV3ghTJracvFNwN7u2w=";
}
