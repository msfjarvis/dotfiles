{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250518020856-0dfb5ce642d0"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
  ];
  hash = "sha256-uCwn/oMWxJFKTQBhvzV2rX6hPIhl6CBFjXOcFKmPdkI=";
}
