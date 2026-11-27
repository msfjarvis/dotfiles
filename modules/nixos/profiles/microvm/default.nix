{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.microvm;
  vms = lib.${namespace}.microvms;
  bridges = map (vm: vm.bridge) (builtins.attrValues vms);
  bridgeSet = lib.concatMapStringsSep ", " (bridge: ''"${bridge}"'') bridges;
  chromeBridge = vms.chrome-cdp.bridge;
in
{
  imports = [ inputs.microvm.nixosModules.host ];

  options.profiles.${namespace}.microvm = {
    enable = lib.mkEnableOption "Enable MicroVM host setup";
  };

  config = lib.mkIf cfg.enable {
    microvm.host.enable = true;

    systemd.network = {
      netdevs = lib.mapAttrs' (
        _: vm:
        lib.nameValuePair "10-${vm.bridge}" {
          netdevConfig = {
            Kind = "bridge";
            Name = vm.bridge;
          };
        }
      ) vms;

      networks =
        (lib.mapAttrs' (
          _: vm:
          lib.nameValuePair "10-${vm.bridge}" {
            matchConfig.Name = vm.bridge;
            addresses = [ { Address = "${vm.gateway}/30"; } ];
            networkConfig = {
              DHCPServer = true;
              IPv4Forwarding = true;
              IPv6AcceptRA = false;
            };
            dhcpServerConfig = {
              EmitDNS = true;
              # Chrome cannot reach tailnet/private resolvers under its egress policy.
              DNS = lib.mkIf (vm.bridge == chromeBridge) [
                "1.1.1.1"
                "8.8.8.8"
              ];
              PoolOffset = 2;
              PoolSize = 1;
            };
            dhcpServerStaticLeases = [
              {
                MACAddress = vm.mac_addr;
                Address = vm.ipv4;
              }
            ];
          }
        ) vms)
        // (lib.mapAttrs' (
          _: vm:
          lib.nameValuePair "10-${vm.tap_if}" {
            matchConfig.Name = vm.tap_if;
            networkConfig.Bridge = vm.bridge;
          }
        ) vms);
    };

    networking.nftables.enable = true;
    networking.firewall.interfaces = lib.genAttrs bridges (_: {
      allowedUDPPorts = [ 67 ];
    });
    networking.nat = {
      enable = true;
      internalInterfaces = bridges;
    };

    # Separate bridges prevent direct L2 traffic; these chains also prevent
    # routing between bridges and restrict the untrusted browser's egress.
    networking.nftables.tables.microvm-isolation = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority -10; policy accept;
          iifname "${chromeBridge}" ct state established,related accept
          iifname "${chromeBridge}" udp sport 68 udp dport 67 accept
          iifname "${chromeBridge}" drop
        }
        chain forward {
          type filter hook forward priority -10; policy accept;
          iifname { ${bridgeSet} } oifname { ${bridgeSet} } drop
          iifname "${chromeBridge}" meta nfproto ipv6 drop
          iifname "${chromeBridge}" ip daddr { 0.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16, 198.18.0.0/15, 224.0.0.0/4, 240.0.0.0/4 } drop
        }
      '';
    };
  };
}
