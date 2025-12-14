{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20251214022152-caac4b6be0d4"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20251017124604-ca540216a266"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20251120182636-39d279ab4233"
    "github.com/greenpau/caddy-security@v0.0.0-20250325161856-83609dec14a4"
  ];
  hash = "sha256-lTnvY73PMGT/JlpraTGxcxfhq79rZMdrC/aFz78/zAQ=";
}
