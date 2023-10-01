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
    defaultGateway = "10.201.154.36";
    defaultGateway6 = {
      address = "2001:bc8:5080:7512::";
      interface = "ens2";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      ens2 = {
        ipv4.addresses = [
          {
            address = "10.201.154.37";
            prefixLength = 31;
          }
        ];
        ipv6.addresses = [
          {
            address = "2001:bc8:5080:7512::1";
            prefixLength = 64;
          }
          {
            address = "fe80::dc30:14ff:fe13:13";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "10.201.154.36";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "2001:bc8:5080:7512::";
            prefixLength = 128;
          }
        ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="de:30:14:13:00:13", NAME="ens2"
  '';
}
