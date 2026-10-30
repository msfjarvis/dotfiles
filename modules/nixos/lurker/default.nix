{
  config,
  lib,
  pkgs,
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
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
  networkName = "lurker-dns";
  bridgeName = "br-lurker";
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
      type = types.str;
      default = "lurker";
      example = "lurker";
      description = "Tailscale hostname to expose Lurker under through Caddy.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = config.virtualisation.oci-containers.backend == "podman";
          message = "The Lurker preview network requires the Podman OCI backend.";
        }
      ];

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 root root - -"
      ];

      # Use a new network so an existing auto-named lurker bridge can coexist
      # during migration. Podman's default network lacks container-name DNS.
      systemd.services.lurker-network = {
        description = "Create the Lurker container network";
        before = [
          "podman-lurker.service"
          "podman-lurker-previews.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.podman}/bin/podman network exists ${networkName} || ${pkgs.podman}/bin/podman network create --interface-name ${bridgeName} ${networkName}
        '';
      };

      systemd.services.podman-lurker = {
        requires = [ "lurker-network.service" ];
        after = [ "lurker-network.service" ];
      };
      systemd.services.podman-lurker-previews = {
        requires = [ "lurker-network.service" ];
        after = [ "lurker-network.service" ];
      };

      virtualisation.oci-containers.containers.lurker-previews = {
        image = "ghcr.io/amiantos/lurker-previews:latest";
        autoStart = true;
        # No network-layer private-address filtering is configured here. The
        # decoder's URL SSRF guard remains active, but cannot contain an RCE.
        environment.LURKER_PREVIEWS_ALLOW_PRIVATE = "1";
        extraOptions = [
          "--pull=always"
          "--network=${networkName}"
          "--read-only"
          "--tmpfs=/tmp:rw,noexec,nosuid,size=256m"
          "--cap-drop=all"
          "--security-opt=no-new-privileges"
          "--memory=512m"
          "--memory-swap=512m"
          "--pids-limit=128"
          "--ipc=none"
        ];
      };

      virtualisation.oci-containers.containers.lurker = {
        image = "ghcr.io/amiantos/lurker:2.6.2";
        autoStart = true;
        ports = [ portMapping ];
        volumes = [
          "${cfg.dataDir}:/app/data"
        ];
        environment = {
          NODE_ENV = "production";
          PORT = "8015";
          DATABASE_PATH = "/app/data/lurker.db";
          WEBAUTHN_RP_ID = "${cfg.domain}.${tailnetDomain}";
          WEBAUTHN_RP_NAME = "Lurker";
          WEBAUTHN_ORIGIN = "https://${cfg.domain}.${tailnetDomain}";
          VAPID_SUBJECT = "mailto:trash_lurker@msfjarvis.dev";
          USER_AGENT_CONTACT = "https://msfjarvis.dev/";
          LURKER_BOUNCER_ENABLED = "true";
          LURKER_BOUNCER_PORT = "6667";
          LURKER_PREVIEWS_URL = "http://lurker-previews:8030";
          LURKER_PREVIEW_CACHE_MODE = "local";
          LURKER_TRUST_PROXY = "true";
        }
        // cfg.extraEnvironment;
        extraOptions = [
          "--pull=always"
          "--network=${networkName}"
        ];
      }
      // optionalAttrs (cfg.environmentFile != null) {
        inherit (cfg) environmentFile;
      };

      networking.firewall.interfaces.${bridgeName} = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        cfg.port
        6667
      ];

      services.caddy.virtualHosts = mkTailscaleVHost cfg.domain ''
        import blackholeCrawlers
        encode gzip zstd
        reverse_proxy ${cfg.listenAddress}:${portString}
      '';
    }
  ]);
}
