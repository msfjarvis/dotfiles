{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260118022810-f2f95ed935db"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20251017124604-ca540216a266"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20251120182636-39d279ab4233"
    "github.com/greenpau/caddy-security@v0.0.0-20250325161856-83609dec14a4"
  ];
  hash = "sha256-1Du5Ur3eO9dx1AhQQ2mxA3ax34jK9nf7wIHdkkdZTIo=";
}
