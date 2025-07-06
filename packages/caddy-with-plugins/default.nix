{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250706022202-8b80591478db"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
  ];
  hash = "sha256-aARMndSsHXFXh2AYa7rFRuP71HjQXigZJk2mb3d9O6g=";
}
