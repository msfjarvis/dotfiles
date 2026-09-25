{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20260921201743-474e615dc02d"
    "github.com/rsp2k/caddy-gitea-pages@v0.0.0-20250609073252-9bb99965619a"
    "github.com/msfjarvis/caddy-tailscale@v0.0.0-20260925133509-b32014b4dfa8"
    "github.com/greenpau/caddy-security@v0.0.0-20260922175619-7c9cb25f29ee"
    "github.com/porech/caddy-maxmind-geolocation@v0.0.0-20250305164927-9066f91c9696"
    "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
  ];
  hash = "sha256-nK7qOjqs7QEZhczc8vhcpxZPxB1TcpK0uoBtgunBwJY=";
}
