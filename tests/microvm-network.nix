{ system, lib }:
let
  inherit (system) config;
  vms = (import ../lib/microvms.nix).microvms;
  hosts = builtins.attrValues vms;
  unique = xs: builtins.length xs == builtins.length (lib.unique xs);
  hostRule = config.networking.nftables.tables.microvm-isolation.content;
  guest = config.microvm.vms.chrome-cdp.flake.nixosConfigurations.chrome-cdp;
  unrestrictedGuest = guest.extendModules {
    modules = [
      ({ lib, ... }: {
        profiles.jarvis.microvm-guest.network = {
          publicOnly = lib.mkForce false;
          dnsServers = lib.mkForce [ ];
        };
      })
    ];
  };
  unrestrictedHost =
    (system.extendModules {
      modules = [
        ({ lib, ... }: {
          microvm.vms.chrome-cdp = {
            flake = lib.mkForce null;
            evaluatedConfig = unrestrictedGuest;
          };
        })
      ];
    }).config;
  stashGuest = config.microvm.vms.stash.flake.nixosConfigurations.stash;
  restrictedStash = stashGuest.extendModules {
    modules = [
      {
        profiles.jarvis.microvm-guest.network = {
          publicOnly = true;
          dnsServers = [ "9.9.9.9" ];
        };
      }
    ];
  };
  twoRestrictedHost =
    (system.extendModules {
      modules = [
        ({ lib, ... }: {
          microvm.vms.stash = {
            flake = lib.mkForce null;
            evaluatedConfig = restrictedStash;
          };
        })
      ];
    }).config;
  has = needle: haystack: builtins.match ".*${needle}.*" haystack != null;
  configured =
    vm:
    let
      bridge = config.systemd.network.networks."10-${vm.bridge}";
      tap = config.systemd.network.networks."10-${vm.tap_if}";
    in
    bridge.addresses == [ { Address = "${vm.gateway}/30"; } ]
    && bridge.networkConfig.DHCPServer
    && bridge.networkConfig.IPv4Forwarding
    &&
      bridge.dhcpServerStaticLeases == [
        {
          MACAddress = vm.mac_addr;
          Address = vm.ipv4;
        }
      ]
    && tap.networkConfig.Bridge == vm.bridge
    && builtins.elem vm.bridge config.networking.nat.internalInterfaces
    && builtins.elem 67 config.networking.firewall.interfaces.${vm.bridge}.allowedUDPPorts;
in
assert unique (map (vm: vm.bridge) hosts);
assert unique (map (vm: vm.gateway) hosts);
assert unique (map (vm: vm.ipv4) hosts);
assert unique (map (vm: vm.tap_if) hosts);
assert builtins.all configured hosts;
assert !(builtins.elem "microvm0" config.networking.nat.internalInterfaces);
assert
  config.systemd.network.networks."10-vmbr-a3".dhcpServerConfig.DNS == [
    "1.1.1.1"
    "8.8.8.8"
  ];
assert has ''iifname \{ "vmbr-a3" \} ct state established,related accept'' hostRule;
assert has ''iifname \{ "vmbr-a3" \} udp sport 68 udp dport 67 accept'' hostRule;
assert has ''iifname \{ "vmbr-a3" \} drop'' hostRule;
assert has ''iifname \{ .* \} oifname \{ .* \} drop'' hostRule;
assert has ''iifname \{ "vmbr-a3" \} meta nfproto ipv6 drop'' hostRule;
assert has ''iifname \{ "vmbr-a3" \} ip daddr.*10.0.0.0/8.*192.168.0.0/16.*drop'' hostRule;
assert
  !(has ''iifname \{ "vmbr-a3" \} drop'' unrestrictedHost.networking.nftables.tables.microvm-isolation.content);
assert !(unrestrictedHost.systemd.network.networks."10-vmbr-a3".dhcpServerConfig ? DNS);
assert
  twoRestrictedHost.systemd.network.networks."10-vmbr-a1".dhcpServerConfig.DNS == [ "9.9.9.9" ];
assert has ''iifname \{ "vmbr-a3", "vmbr-a1" \} drop''
  twoRestrictedHost.networking.nftables.tables.microvm-isolation.content;
true
