let
  caddy = import ./caddy.nix;
  nixConfig = import ./nixConfig.nix;
  ports = import ./ports.nix;
  vsock = import ./vsock.nix;
in
{
  inherit (caddy) tailnetDomain mkTailscaleVHost;
  inherit (nixConfig) mkNixConfig;
  inherit (ports) ports;
  inherit (vsock) vsock;
}
