{ system }:
let
  inherit (system) config;
  disabled =
    (system.extendModules {
      modules = [ ({ lib, ... }: { services.jarvis.remote-chrome.enable = lib.mkForce false; }) ];
    }).config;
  customPort =
    (system.extendModules {
      modules = [ { services.jarvis.remote-chrome.port = 9333; } ];
    }).config;
  browser = config.systemd.services.remote-chrome.serviceConfig;
  daemon = config.systemd.services.remote-chrome-tailscaled.serviceConfig;
  setup = config.systemd.services.remote-chrome-tailscale-setup;
  has = needle: haystack: (builtins.match ".*${needle}.*" haystack) != null;
in
assert has "--remote-debugging-address=127.0.0.1" browser.ExecStart;
assert has "--remote-debugging-port=9223" browser.ExecStart;
assert has "--tun=userspace-networking" daemon.ExecStart;
assert has "--advertise-tags=tag:chrome-cdp" setup.script;
assert has "serve --bg --tcp=9222 tcp://127.0.0.1:9223" setup.script;
assert has "serve --bg --tcp=9333 tcp://127.0.0.1:9223"
  customPort.systemd.services.remote-chrome-tailscale-setup.script;
assert !(builtins.elem 9222 config.networking.firewall.allowedTCPPorts);
assert
  !(builtins.elem 9222 (config.networking.firewall.interfaces.tailscale0.allowedTCPPorts or [ ]));
assert !(disabled.systemd.services ? remote-chrome);
assert !(disabled.systemd.services ? remote-chrome-tailscaled);
assert !(disabled.systemd.services ? remote-chrome-tailscale-setup);
true
