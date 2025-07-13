{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250713022654-754d5e0a690d"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250530190508-579fbc2c77a7"
  ];
  hash = "sha256-fcY8973CKg3c+C9vrtb1Bqs0sWGrfxT0VHx5MlHoLGs=";
}
