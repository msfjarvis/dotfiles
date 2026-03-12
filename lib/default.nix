let
  caddy = import ./caddy.nix;
  nixConfig = import ./nixConfig.nix;
  ports = import ./ports.nix;
  microvms = import ./microvms.nix;
in
{
  inherit (caddy) tailnetDomain mkTailscaleVHost;
  inherit (nixConfig) mkNixConfig;
  inherit (ports) ports;
  inherit (microvms) microvms;
}
