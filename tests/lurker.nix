{ system }:
let
  inherit (system) config;
  disabled =
    (system.extendModules {
      modules = [
        ({ lib, ... }: { services.jarvis.lurker.enable = lib.mkForce false; })
      ];
    }).config;
  firewall = config.networking.firewall;
  network = config.systemd.services.lurker-network;
  containers = config.virtualisation.oci-containers.containers;
  has = builtins.elem;
in
assert firewall.interfaces.br-lurker.allowedTCPPorts == [ 53 ];
assert firewall.interfaces.br-lurker.allowedUDPPorts == [ 53 ];
assert !(has 53 firewall.allowedTCPPorts);
assert !(has 53 firewall.allowedUDPPorts);
assert
  builtins.match ".*podman network exists lurker-dns.*podman network create --interface-name br-lurker lurker-dns\n" network.script
  != null;
assert has "--network=lurker-dns" containers.lurker.extraOptions;
assert has "--network=lurker-dns" containers.lurker-previews.extraOptions;
assert has "lurker-network.service" config.systemd.services.podman-lurker.requires;
assert has "lurker-network.service" config.systemd.services.podman-lurker-previews.requires;
assert !(disabled.networking.firewall.interfaces ? br-lurker);
assert !(disabled.systemd.services ? lurker-network);
true
