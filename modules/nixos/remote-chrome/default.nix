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
  socket = "/run/remote-chrome-tailscale/tailscaled.sock";
  tailscale = "${lib.getExe config.services.tailscale.package} --socket=${socket}";
in
{
  options.services.${namespace}.remote-chrome = {
    enable = lib.mkEnableOption "a Tailscale-only remote Chrome DevTools endpoint";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9222;
      description = "DevTools port exposed on the dedicated Tailscale node.";
    };
    authKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing a Tailscale OAuth secret authorized to register tag:chrome-cdp.";
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

    # A separate userspace node gives the browser its own ACL identity without
    # changing Matara's server tag or exposing CDP on Matara's Tailscale IP.
    systemd.services.remote-chrome-tailscaled = {
      description = "Tailscale node for remote Chrome";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        RuntimeDirectory = "remote-chrome-tailscale";
        StateDirectory = "remote-chrome-tailscale";
        ExecStart = "${config.services.tailscale.package}/bin/tailscaled --tun=userspace-networking --port=0 --socket=${socket} --state=%S/remote-chrome-tailscale/tailscaled.state";
        Restart = "on-failure";
      };
    };

    systemd.services.remote-chrome-tailscale-setup = {
      description = "Register and serve the remote Chrome Tailscale node";
      wantedBy = [ "multi-user.target" ];
      requires = [ "remote-chrome-tailscaled.service" ];
      after = [ "remote-chrome-tailscaled.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 5;
      };
      script = ''
        ${tailscale} up --auth-key ${lib.escapeShellArg "file:${toString cfg.authKeyFile}"} --timeout=60s \
          --hostname=chrome-cdp --advertise-tags=tag:chrome-cdp
        ${tailscale} serve reset
        ${tailscale} serve --bg --tcp=${toString cfg.port} tcp://127.0.0.1:${toString internalPort}
      '';
    };
  };
}
