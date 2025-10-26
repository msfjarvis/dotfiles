{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20251024031446-47284f3bbc67"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20251017124604-ca540216a266"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20251022200233-71fcff3c6686"
    "github.com/greenpau/caddy-security@v0.0.0-20250325161856-83609dec14a4"
  ];
  hash = "sha256-h/qImleyr31fV9sr+fdzWZK507pz/fj1P05FCKYfA0k=";
}
