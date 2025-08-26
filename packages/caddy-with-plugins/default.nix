{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250824020956-a4d30f5304a9"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20250530190508-579fbc2c77a7"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20250723144432-4e8672b140b0"
  ];
  hash = "sha256-vycci2tngwbx2TLdO5diw93Wm8WMUx/5Vx6b0YWeJfw=";
}
