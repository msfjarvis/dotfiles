{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250706022202-8b80591478db"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250530190508-579fbc2c77a7"
  ];
  hash = "sha256-E8sf1X+y52ZSY2cwg3jBiBfTBgg/4hhFhWYuhmdxREU=";
}
