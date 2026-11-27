{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.remote-chrome;
  internalPort = 9223;
in
{
  options.services.${namespace}.remote-chrome = {
    enable = lib.mkEnableOption "a Tailscale-only remote Chrome DevTools endpoint";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9222;
      description = "DevTools port exposed on the Tailscale interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "remote-chrome requires Tailscale.";
      }
      {
        assertion = cfg.port != internalPort;
        message = "remote-chrome's exposed port must differ from its loopback port.";
      }
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.port ];

    systemd.services.remote-chrome = {
      description = "Headless Chromium for remote crawling";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        CacheDirectory = "remote-chrome";
        StateDirectory = "remote-chrome";
        Environment = "HOME=%C/remote-chrome";
        ExecStart = lib.concatStringsSep " " [
          "${lib.getExe pkgs.chromium}"
          "--headless"
          "--no-sandbox"
          "--disable-gpu"
          "--disable-dev-shm-usage"
          "--remote-debugging-address=127.0.0.1"
          "--remote-debugging-port=${toString internalPort}"
          "--hide-scrollbars"
          "--user-data-dir=%S/remote-chrome"
        ];
        Restart = "on-failure";
        DevicePolicy = "closed";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
    };

    # Chrome binds DevTools to loopback. Socket activation limits the forwarder
    # to packets arriving through Tailscale, including when addresses change.
    systemd.sockets.remote-chrome-proxy = {
      description = "Tailscale-only Chrome DevTools socket";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = cfg.port;
        BindToDevice = "tailscale0";
        Accept = true;
      };
    };

    systemd.services."remote-chrome-proxy@" = {
      description = "Chrome DevTools connection forwarder";
      serviceConfig = {
        DynamicUser = true;
        StandardInput = "socket";
        ExecStart = "${lib.getExe pkgs.socat} STDIO TCP4:127.0.0.1:${toString internalPort}";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
