{ system }:
let
  inherit (system) config;
  clustered =
    (system.extendModules {
      modules = [ { services.jarvis.prometheus.alertmanager.clusterEnabled = true; } ];
    }).config;
  exporter = config.systemd.services.prometheus-tailscale-exporter;
in
assert builtins.elem "--cluster.listen-address=" config.services.prometheus.alertmanager.extraFlags;
assert
  !(builtins.elem "--cluster.listen-address=" clustered.services.prometheus.alertmanager.extraFlags);
assert builtins.elem "network-online.target" exporter.after;
assert builtins.elem "network-online.target" exporter.wants;
assert builtins.elem "systemd-resolved.service" exporter.after;
assert exporter.serviceConfig.Restart == "always";
assert exporter.serviceConfig.RestartSec == "30s";
assert exporter.unitConfig.StartLimitIntervalSec == 0;
true
