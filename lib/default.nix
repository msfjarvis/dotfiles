{ lib, inputs, ... }:
let
  caddy = import ./caddy.nix;
  nixConfig = import ./nixConfig.nix;
  ports = import ./ports.nix;
  secrets = import ./secrets.nix { inherit inputs; };
  services = import ./services.nix { inherit lib; };
in
{
  inherit (caddy) tailnetDomain mkTailscaleVHost;
  inherit (nixConfig) mkNixConfig;
  inherit (ports) ports;
  inherit (secrets) mkSystemSecret;
  inherit (services) mkGraphicalService mkServiceOption;
}
