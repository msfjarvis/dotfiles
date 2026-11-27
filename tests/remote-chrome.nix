{ host, guest }:
let
  inherit (host) config;
  vm = guest.config;
  disabled =
    (guest.extendModules {
      modules = [ ({ lib, ... }: { services.jarvis.remote-chrome.enable = lib.mkForce false; }) ];
    }).config;
  browser = vm.systemd.services.remote-chrome.serviceConfig;
  socket = vm.systemd.sockets.remote-chrome-proxy.socketConfig;
  has = needle: haystack: (builtins.match ".*${needle}.*" haystack) != null;
in
assert builtins.elem "chrome-cdp" config.microvm.autostart;
assert config.microvm.vms ? chrome-cdp;
assert !(config.systemd.services.install-microvm-chrome-cdp.unitConfig ? ConditionPathExists);
assert builtins.elem "install-microvm-chrome-cdp.service"
  config.systemd.services."microvm@chrome-cdp".requires;
assert !config.services.jarvis.remote-chrome.enable;
assert vm.microvm.guest.enable;
assert builtins.any (
  volume:
  volume.mountPoint == "/var/lib" && volume.size == 2048 && volume.image == "chrome-cdp-data.img"
) vm.microvm.volumes;
assert vm.time.timeZone == "Asia/Kolkata";
assert vm.systemd.timers.remote-chrome-cleanup.timerConfig.OnCalendar == "*-*-* 00:00:00";
assert vm.systemd.timers.remote-chrome-cleanup.timerConfig.Persistent;
assert has "systemctl stop remote-chrome.service" vm.systemd.services.remote-chrome-cleanup.script;
assert has "find /var/lib/private/remote-chrome -mindepth 1 -delete"
  vm.systemd.services.remote-chrome-cleanup.script;
assert vm.sops.secrets == { };
assert vm.microvm.interfaces != [ ];
assert builtins.all (share: share.readOnly) vm.microvm.shares;
assert !(builtins.elem 22 vm.networking.firewall.allowedTCPPorts);
assert has "--remote-debugging-address=127.0.0.1" browser.ExecStart;
assert has "--remote-debugging-port=9223" browser.ExecStart;
assert socket.ListenStream == "10.100.0.4:9222";
assert socket.FreeBind;
assert socket.Accept;
assert has "ip saddr 10.100.0.1 ip daddr 10.100.0.4 tcp dport 9222 accept"
  vm.networking.firewall.extraInputRules;
assert !(builtins.elem 9222 vm.networking.firewall.allowedTCPPorts);
assert config.services.caddy.tailscaleNodes.chrome-cdp.tags == [ "tag:chrome-cdp" ];
assert has "bind tailscale/chrome-cdp"
  config.services.caddy.virtualHosts."http://:9222".extraConfig;
assert has "reverse_proxy 10.100.0.4:9222"
  config.services.caddy.virtualHosts."http://:9222".extraConfig;
assert !(disabled.systemd.services ? remote-chrome);
assert !(disabled.systemd.services ? remote-chrome-cleanup);
assert !(disabled.systemd.timers ? remote-chrome-cleanup);
assert !(disabled.systemd.sockets ? remote-chrome-proxy);
true
