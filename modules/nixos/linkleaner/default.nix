{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.linkleaner;
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption types;
in
{
  options.services.${namespace}.linkleaner = {

    enable = mkEnableOption { description = "Whether to configure the linkleaner service"; };

    package = mkPackageOption pkgs.jarvis "linkleaner" { };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      example = "/root/linkleaner-secrets.env";
      description = "Environment file to inject secrets into the configuration.";
    };

    user = mkOption {
      type = types.str;
      default = "linkleaner";
      description = "User account under which linkleaner runs.";
    };

    group = mkOption {
      type = types.str;
      default = "linkleaner";
      description = "Group account under which linkleaner runs.";
    };

  };

  config = mkIf cfg.enable {
    systemd.services.linkleaner = {
      description = "Telegram bot to improve social media previews";

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe cfg.package}";
        EnvironmentFile = cfg.environmentFile;
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

    users.users = mkIf (cfg.user == "linkleaner") {
      linkleaner = {
        inherit (cfg) group;
        createHome = false;
        description = "linkleaner daemon user";
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "linkleaner") {
      linkleaner = {
        gid = null;
      };
    };
  };
}
