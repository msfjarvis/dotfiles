{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.copyparty;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports;
in
{
  options.services.${namespace}.copyparty = {
    enable = mkEnableOption "Run copyparty file server";

    user = mkOption {
      type = types.str;
      default = "copyparty";
      description = "User account under which copyparty runs.";
    };

    group = mkOption {
      type = types.str;
      default = "copyparty";
      description = "Group under which copyparty runs.";
    };

    subdomain = mkOption {
      type = types.str;
      default = "${config.networking.hostName}-files";
      description = "Tailscale subdomain for the Caddy virtual host.";
    };

    volumes = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.path;
              description = "Physical path to serve";
            };
            access = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Access control rules";
            };
          };
        }
      );
      default = { };
      description = ''
        Volume definitions for copyparty.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.copyparty.override {
        withHashedPasswords = false;
        withCertgen = false;
        withThumbnails = false;
        withFastThumbnails = true;
        withMediaProcessing = false;
        withBasicAudioMetadata = false;
        withZeroMQ = false;
        withFTP = false;
        withTFTP = false;
        withFTPS = false;
        withSMB = false;
        withMagic = false;
      };
      description = "copyparty package to use.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional settings to pass to copyparty.";
    };
  };

  config = mkIf cfg.enable {
    services.copyparty = {
      enable = true;
      inherit (cfg)
        package
        user
        group
        volumes
        ;
      mkHashWrapper = true;
      settings = {
        i = "127.0.0.1";
        p = toString ports.copyparty;
        theme = 2;
        e2dsa = true;
        e2ts = true;
        re-maxage = 3600;
        stats = true;
      }
      // cfg.extraSettings;
    };

    users.users = mkIf (cfg.user == "copyparty") {
      copyparty = {
        inherit (cfg) group;
        description = "copyparty daemon user";
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "copyparty") {
      copyparty = { };
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "copyparty";
        metrics_path = "/.cpr/metrics";
        static_configs = [
          { targets = [ "${config.services.copyparty.settings.i}:${toString ports.copyparty}" ]; }
        ];
      }
    ];

    services.caddy.virtualHosts = mkTailscaleVHost cfg.subdomain ''
      reverse_proxy ${config.services.copyparty.settings.i}:${toString ports.copyparty}
    '';
  };
}
