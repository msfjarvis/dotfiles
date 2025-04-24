{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "github.com/jasonlovesdoggo/caddy-defender@v0.8.5"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
  ];
  hash = "sha256-wy0VyV0v2POwC2OyV+cVHkl9JFpJcYG92fuCT/LDPZ8=";
}
