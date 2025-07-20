{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250717022813-f47da651f1b8"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250530190508-579fbc2c77a7"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
  ];
  hash = "sha256-lGp8ekuEHPKLdC3ZfMfZUR7oZpyaBMxHzzT51LFxw1M=";
}
