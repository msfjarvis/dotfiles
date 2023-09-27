{lib, ...}: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    hostName = "wailord";
    networkmanager.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
    defaultGateway = "143.244.128.1";
    defaultGateway6 = {
      address = "2400:6180:100:d0::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "143.244.142.121";
            prefixLength = 20;
          }
          {
            address = "10.47.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2400:6180:100:d0::125:2001";
            prefixLength = 64;
          }
          {
            address = "fe80::b84e:8eff:fe90:2489";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "143.244.128.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "2400:6180:100:d0::1";
            prefixLength = 128;
          }
        ];
      };
      eth1 = {
        ipv4.addresses = [
          {
            address = "10.122.0.2";
            prefixLength = 20;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::449:7bff:fe34:4a6a";
            prefixLength = 64;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="ba:4e:8e:90:24:89", NAME="eth0"
    ATTR{address}=="06:49:7b:34:4a:6a", NAME="eth1"
  '';
}
