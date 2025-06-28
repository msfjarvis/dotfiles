{ caddy, ... }:
caddy.withPlugins {
  plugins = [
    "pkg.jsn.cam/caddy-defender@v0.0.0-20250622022107-8471c72ed5ea"
    "github.com/tailscale/caddy-tailscale@v0.0.0-20250508175905-642f61fea3cc"
  ];
  hash = "sha256-Qkxsas7IfAb+Y+i+YJ4TpchuuzMLppNFYriizxNS2KE=";
}
