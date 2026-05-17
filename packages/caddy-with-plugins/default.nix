{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260517010834-a8ec7e69208c"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260503011730-493ff9288d56"
    "github.com/greenpau/caddy-security@v0.0.0-20260425125447-e03784fa0581"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-boVZ/vLmbXWKzYcoml5B1ysjFQLzbUEKXT9W0yZQ1KE=";
}
