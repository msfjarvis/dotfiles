{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20251019020711-a8c9a59cbbd6"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20251017124604-ca540216a266"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20251022200233-71fcff3c6686"
    "github.com/greenpau/caddy-security@v0.0.0-20250325161856-83609dec14a4"
  ];
  hash = "sha256-seqSshLBAf8YGHS1qWM0luHN+XpciRPtSJUKZOlqwoA=";
}
