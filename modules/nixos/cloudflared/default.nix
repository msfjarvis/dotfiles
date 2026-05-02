{ config, lib, ... }:
{
  sops.secrets.cf-tunnel-cert = {
    sopsFile = lib.snowfall.fs.get-file "secrets/cloudflare/tunnel-cert.pem";
    format = "binary";
  };
  services.cloudflared = {
    certificateFile = config.sops.secrets.cf-tunnel-cert.path;
  };
}
