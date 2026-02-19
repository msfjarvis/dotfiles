{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.caldav-api;
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports;
in
{
  options.services.${namespace}.caldav-api = {

    enable = mkEnableOption { description = "Whether to configure the caldav-api service"; };

    package = mkPackageOption pkgs.jarvis "caldav-api" { };

    tailnetDomain = mkOption {
      type = types.str;
      default = "caldav-api";
      example = "caldav";
      description = "Subdomain name for the Tailscale virtual host";
    };

  };

  config = mkIf cfg.enable {
    sops.secrets.caldav-api = {
      sopsFile = lib.snowfall.fs.get-file "secrets/caldav-api.env";
      format = "dotenv";
      restartUnits = [ "caldav-api.service" ];
    };

    systemd.services.caldav-api = {
      description = "CalDAV HTTP API service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = getExe cfg.package;
        EnvironmentFile = [ config.sops.secrets.caldav-api.path ];
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "simple";

        # Security Hardening
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        NoNewPrivileges = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [
          "/dev/shm"
          "/run"
          "/tmp"
        ];
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = [ "@system-service" ];
      };
    };

    services.caddy.virtualHosts = mkTailscaleVHost cfg.tailnetDomain ''
      reverse_proxy 127.0.0.1:${toString ports.caldav-api}
    '';
  };
}
