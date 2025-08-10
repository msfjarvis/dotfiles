{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250805020509-412974614b7e"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250530190508-579fbc2c77a7"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20250723144432-4e8672b140b0"
  ];
  hash = "sha256-LjT5660NlyvR/APCTNgdhgFvEbPU0PkDF47TwW0H10w=";
}
