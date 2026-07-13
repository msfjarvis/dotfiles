{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.remote-pi-relay;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports;
  portString = toString cfg.port;
  portMapping =
    if cfg.listenAddress == "0.0.0.0" then
      "${portString}:3000"
    else
      "${cfg.listenAddress}:${portString}:3000";
in
{
  options.services.${namespace}.remote-pi-relay = {
    enable = mkEnableOption "Remote Pi WebSocket relay";

    image = mkOption {
      type = types.str;
      default = "docker.io/jacobmoura7/remote-pi-relay:v0.2.2@sha256:b88b1984a20170debf569937b5a1245dd325b38aba3ef46f327962b733be446a";
      description = "Pinned upstream Remote Pi Relay OCI image.";
    };

    listenAddress = mkOption {
      type = types.enum [
        "127.0.0.1"
        "0.0.0.0"
      ];
      default = "127.0.0.1";
      description = "Host address on which to publish the relay container port.";
    };

    port = mkOption {
      type = types.port;
      default = ports.remote-pi-relay;
      description = "Host TCP port mapped to the relay container's port 3000.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/remote-pi-relay";
      description = "Persistent host directory mounted at /data for mesh.db.";
    };

    logLevel = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "info";
      description = "Optional RUST_LOG filter for the relay process.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the relay's host port in the firewall.";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "remote-pi-relay";
      description = "Tailscale hostname to expose through Caddy.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 root root - -"
      ];

      virtualisation.oci-containers.containers.remote-pi-relay = {
        inherit (cfg) image;
        autoStart = true;
        ports = [ portMapping ];
        volumes = [
          "${cfg.dataDir}:/data"
        ];
        environment = {
          REMOTEPI_RELAY_PORT = "3000";
          REMOTEPI_MESH_DB_PATH = "/data/mesh.db";
        }
        // optionalAttrs (cfg.logLevel != null) {
          RUST_LOG = cfg.logLevel;
        };
        extraOptions = [
          "--pull=always"
        ];
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    }
    (mkIf (cfg.domain != null) {
      services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
        reverse_proxy 127.0.0.1:${portString}
      '';
    })
  ]);
}
