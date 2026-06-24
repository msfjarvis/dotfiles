{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.lurker;
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
      "${portString}:8015"
    else
      "${cfg.listenAddress}:${portString}:8015";
in
{
  options.services.${namespace}.lurker = {
    enable = mkEnableOption "Lurker IRC bouncer web app";

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host address to bind the Lurker HTTP port on.";
    };

    port = mkOption {
      type = types.port;
      default = ports.lurker;
      description = "Host port to expose Lurker on.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/lurker";
      description = "Persistent data directory for Lurker state and uploads.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/lurker.env";
      description = "Optional environment file for secrets or additional runtime settings.";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        WEBAUTHN_RP_ID = "lurker.example.com";
        WEBAUTHN_RP_NAME = "Lurker";
        WEBAUTHN_ORIGIN = "https://lurker.example.com";
      };
      description = "Additional environment variables to pass to the Lurker container.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the configured Lurker port in the firewall.";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "lurker";
      description = "Tailscale hostname to expose Lurker under through Caddy.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 root root - -"
      ];

      virtualisation.oci-containers.containers.lurker = {
        image = "ghcr.io/amiantos/lurker:1.0.2";
        autoStart = true;
        ports = [ portMapping ];
        volumes = [
          "${cfg.dataDir}:/app/data"
        ];
        environment = {
          NODE_ENV = "production";
          PORT = "8015";
          DATABASE_PATH = "/app/data/lurker.db";
        }
        // cfg.extraEnvironment;
        extraOptions = [
          "--pull=always"
        ];
      }
      // optionalAttrs (cfg.environmentFile != null) {
        inherit (cfg) environmentFile;
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    }
    (mkIf (cfg.domain != null) {
      services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
        import blackholeCrawlers
        encode gzip zstd
        reverse_proxy ${cfg.listenAddress}:${portString}
      '';
    })
  ]);
}
