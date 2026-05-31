{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260531013032-f70e3100b2a2"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260522153743-9cc53305dea6"
    "github.com/greenpau/caddy-security@v0.0.0-20260425125447-e03784fa0581"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
  ];
  hash = "sha256-p/Jhe4MI6+sE4Z+Y2hdEjKq7YKXd5i0VXwNdP/OzjLM=";
}
