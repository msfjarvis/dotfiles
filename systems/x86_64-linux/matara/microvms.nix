{
  inputs,
  lib,
  namespace,
  ...
}:
{
  microvm.host.enable = true;

  microvm.vms = {
    "stash" = {
      # Host build-time reference to where the MicroVM NixOS is defined
      # under nixosConfigurations
      flake = inputs.self;
      # Specify from where to let `microvm -u` update later on
      updateFlake = "git+file:///home/msfjarvis/git-repos/dotfiles";
    };
  };

  microvm.autostart = [
    "stash"
  ];

  # Bridge for microvm tap interfaces
  systemd.network = {
    netdevs."10-microvm0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "microvm0";
      };
    };

    networks = {
      # Assign host-side IP on the bridge and serve DHCP with static leases
      "10-microvm0" = {
        matchConfig.Name = "microvm0";
        addresses = [ { Address = "10.100.0.1/24"; } ];
        networkConfig = {
          DHCPServer = true;
          IPv4Forwarding = true;
        };
        dhcpServerConfig.EmitDNS = true;
        dhcpServerStaticLeases = lib.mapAttrsToList (_name: vm: {
          MACAddress = vm.mac_addr;
          Address = vm.ipv4;
        }) lib.${namespace}.microvms;
      };

      # Attach all vm-* tap interfaces to the bridge
      "10-microvm-tap" = {
        matchConfig.Name = "vm-*";
        networkConfig.Bridge = "microvm0";
      };
    };
  };

  # Allow DHCP from VMs and forward their traffic via NAT
  networking.firewall.allowedUDPPorts = [ 67 ];
  networking.nat = {
    enable = true;
    internalInterfaces = [ "microvm0" ];
  };
}
