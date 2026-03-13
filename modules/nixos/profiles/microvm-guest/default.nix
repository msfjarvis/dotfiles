{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.microvm-guest;
  inherit (lib)
    mkEnableOption
    mkOption
    mkMerge
    mkIf
    types
    ;
in
{
  imports = [ inputs.microvm.nixosModules.microvm ];

  options.profiles.${namespace}.microvm-guest = {
    enable = mkEnableOption "microVM guest profile";
    mac_addr = mkOption {
      type = types.str;
      description = "MAC address for the microVM tap interface";
    };
    tap_if = mkOption {
      type = types.str;
      description = "Tap interface ID";
    };
    vsock = mkOption {
      type = types.int;
      description = "VSOCK CID";
    };
  };

  config = mkMerge [
    {
      microvm.guest.enable = lib.mkDefault false;
    }
    (mkIf cfg.enable {
      microvm.guest.enable = true;

      networking.useNetworkd = true;
      systemd.network.enable = true;

      profiles.${namespace} = {
        server = {
          enable = true;
          microVM = true;
        };
      };

      systemd.network.networks."10-eth" = {
        matchConfig.MACAddress = cfg.mac_addr;
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };
        dhcpV4Config = {
          ClientIdentifier = "mac";
        };
      };

      microvm = {
        interfaces = [
          {
            type = "tap";
            id = cfg.tap_if;
            mac = cfg.mac_addr;
          }
        ];

        shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
        ];

        # Integrate with systemd-machined
        registerWithMachined = true;

        # Enable SSH over VSOCK
        vsock = {
          cid = cfg.vsock;
          ssh.enable = true;
        };

        hypervisor = "qemu";
        qemu.serialConsole = true;
      };

      services.qemuGuest.enable = true;

      system.stateVersion = "26.05";
    })
  ];
}
