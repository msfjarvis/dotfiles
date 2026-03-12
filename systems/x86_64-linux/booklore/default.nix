{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
let
  vmConfig = lib.${namespace}.microvms.${config.networking.hostName};
  inherit (lib.${namespace}) ports;
in
{
  imports = [ inputs.microvm.nixosModules.microvm ];
  networking.hostName = "booklore";
  networking.useNetworkd = true;
  systemd.network.enable = true;

  profiles.${namespace} = {
    server = {
      enable = true;
      microVM = true;
    };
  };

  # Pick up an IP from the host bridge DHCP server.
  # The host issues a static lease for this VM's MAC.
  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = vmConfig.mac_addr;
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = false;
    };
    dhcpV4Config = {
      ClientIdentifier = "mac";
    };
  };
  microvm.interfaces = [
    {
      type = "tap";
      id = vmConfig.tap_if;
      mac = vmConfig.mac_addr;
    }
  ];

  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
  ];
  microvm.vcpu = 1;
  microvm.volumes = [
    {
      mountPoint = "/var/lib/booklore";
      image = "booklore.img";
      size = 1024 * 1;
    }
  ];
  microvm.mem = 512;
  # Integrate with systemd-machined
  microvm.registerWithMachined = true;

  # Enable SSH over VSOCK
  microvm.vsock = {
    cid = vmConfig.vsock;
    ssh.enable = true;
  };
  microvm.hypervisor = "qemu";
  microvm.qemu.serialConsole = true;
  services.qemuGuest.enable = true;
  system.stateVersion = "26.05";

  services.booklore = {
    enable = true;
    database.createLocally = true;
    nginx.enable = false;
    host = "127.0.0.1";
    port = ports.booklore;
  };
}
