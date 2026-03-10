{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260308024645-002ffba5d154"
    "github.com/muety/caddy-plausible-plugin@v0.0.0-20251017124604-ca540216a266"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260308005612-657a6982f08f"
    "github.com/greenpau/caddy-security@v0.0.0-20260309215257-5ab058ddcd6d"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-xz0Qv4mQJeUL4ilb8ohmQEpEiCpBodtiF2dcbpgj+NA=";
}
