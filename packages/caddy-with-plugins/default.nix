{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260405005332-1a65a821f900"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260405010411-6d40db131e67"
    "github.com/greenpau/caddy-security@v0.0.0-20260403154904-fb799584502f"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-WiB3C5isQnNtSY7DcoEZ6ZT5dUEN/lFK1IA3Jc9siGk=";
}
