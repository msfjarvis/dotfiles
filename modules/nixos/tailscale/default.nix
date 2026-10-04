{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.tailscale;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) ports;
in
{
  options.profiles.${namespace}.tailscale = {
    enable = mkEnableOption "Tailscale profile";
  };
  config = mkIf cfg.enable {
    networking = {
      nameservers = [
        "100.100.100.100"
        "8.8.8.8"
        "1.1.1.1"
      ];
      search = [ lib.${namespace}.tailnetDomain ];
    };

    # Enable Tailscale and allow it to provision certificates to caddy
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
      useRoutingFeatures = lib.mkDefault "client";
    };

    sops.secrets.tailscale-exporter = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale-prometheus.env";
      owner = config.services.prometheus.exporters.tailscale.user;
      group = config.services.prometheus.exporters.tailscale.group;
      format = "dotenv";
    };

    services.prometheus = {
      exporters.tailscale = {
        enable = true;
        user = "tailscale-exporter";
        group = "tailscale-exporter";
        port = ports.exporters.tailscale;
        environmentFile = config.sops.secrets.tailscale-exporter.path;
      };
      scrapeConfigs = [
        {
          job_name = "tailscaled_client_metrics";
          static_configs = [
            { targets = [ "127.0.0.1:${toString ports.exporters.tailscale}" ]; }
          ];
        }
      ];
    };

    users.users = {
      tailscale-exporter = {
        group = "tailscale-exporter";
        createHome = false;
        description = "Tailscale Prometheus Exporter";
        isSystemUser = true;
      };
      msfjarvis.packages = with pkgs; [ tailscale ];
    };

    users.groups = {
      tailscale-exporter = {
        gid = null;
      };
    };

  };
}
