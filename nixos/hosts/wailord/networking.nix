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
    defaultGateway = "64.227.136.1";
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
            address = "64.227.139.80";
            prefixLength = 21;
          }
          {
            address = "10.47.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2400:6180:100:d0::a37:2001";
            prefixLength = 64;
          }
          {
            address = "fe80::c424:14ff:fe62:75a1";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "64.227.136.1";
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
            address = "fe80::78ba:c2ff:fe58:41e5";
            prefixLength = 64;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="c6:24:14:62:75:a1", NAME="eth0"
    ATTR{address}=="7a:ba:c2:58:41:e5", NAME="eth1"
  '';
}
