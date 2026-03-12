{
  config,
  lib,
  namespace,
  ...
}:
let
  vmConfig = lib.${namespace}.microvms.${config.networking.hostName};
  inherit (lib.${namespace}) ports;
in
{
  networking.hostName = "booklore";

  profiles.${namespace}.microvm-guest = {
    enable = true;
    inherit (vmConfig) mac_addr tap_if vsock;
  };

  microvm.vcpu = 1;
  microvm.volumes = [
    {
      mountPoint = "/var/lib/booklore";
      image = "booklore.img";
      size = 1024 * 1;
    }
  ];
  microvm.mem = 512;

  services.booklore = {
    enable = true;
    database.createLocally = true;
    nginx.enable = false;
    host = "127.0.0.1";
    port = ports.booklore;
  };
}
