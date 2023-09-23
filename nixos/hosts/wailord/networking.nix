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
    defaultGateway = "167.71.224.1";
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
            address = "167.71.234.64";
            prefixLength = 20;
          }
          {
            address = "10.47.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2400:6180:100:d0::983:c001";
            prefixLength = 64;
          }
          {
            address = "fe80::b091:29ff:fec6:1637";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "167.71.224.1";
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
            address = "fe80::a071:83ff:fed6:5af6";
            prefixLength = 64;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="b2:91:29:c6:16:37", NAME="eth0"
    ATTR{address}=="a2:71:83:d6:5a:f6", NAME="eth1"
  '';
}
