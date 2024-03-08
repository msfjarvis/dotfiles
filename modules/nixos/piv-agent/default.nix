{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.piv-agent;
in {
  options.services.piv-agent = {
    enable = mkEnableOption {
      description = mdDoc "Whether to configure the piv-agent service";
    };
    package = mkPackageOptionMD pkgs.jarvis "piv-agent" {};
  };

  config = mkIf cfg.enable {
    systemd.services.piv-agent = {
      description = "Run piv-agent to forward connections";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve --debug";
        ExecReload = "/bin/kill -HUP $MAINPID";
        ProtectSystem = "strict";
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        IPAddressDeny = "any";
        RestrictAddressFamilies = ["AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        CapabilityBoundingSet = [""];
        SystemCallFilter = ["@system-service" "~@privileged" "@resources"];
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        NoNewPrivileges = true;
        KeyringMode = "private";
        UMask = 0177;
        RuntimeDirectory = "piv-agent";
      };
    };
  };
}
