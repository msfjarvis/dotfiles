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
  socket = config.systemd.sockets.remote-chrome-proxy.socketConfig;
  browser = config.systemd.services.remote-chrome.serviceConfig;
  proxy = config.systemd.services."remote-chrome-proxy@".serviceConfig;
  libHas = needle: haystack: (builtins.match ".*${needle}.*" haystack) != null;
in
assert socket.ListenStream == 9222;
assert socket.BindToDevice == "tailscale0";
assert socket.Accept;
assert builtins.elem 9222 config.networking.firewall.interfaces.tailscale0.allowedTCPPorts;
assert !(builtins.elem 9222 config.networking.firewall.allowedTCPPorts);
assert libHas "--remote-debugging-address=127.0.0.1" browser.ExecStart;
assert libHas "--remote-debugging-port=9223" browser.ExecStart;
assert libHas "TCP4:127.0.0.1:9223" proxy.ExecStart;
assert proxy.StandardInput == "socket";
assert customPort.systemd.sockets.remote-chrome-proxy.socketConfig.ListenStream == 9333;
assert builtins.elem 9333 customPort.networking.firewall.interfaces.tailscale0.allowedTCPPorts;
assert !(disabled.systemd.services ? remote-chrome);
assert !(disabled.systemd.sockets ? remote-chrome-proxy);
true
