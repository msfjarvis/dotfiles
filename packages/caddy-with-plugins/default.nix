{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250620221725-aa75f3e1f131"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
  ];
  hash = "sha256-8Q1HLIxtua2bgreOKWzVPomx3g+ifqZPNqs7d8Mw2To=";
}
