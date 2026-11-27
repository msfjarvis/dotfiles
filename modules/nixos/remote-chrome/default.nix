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
    enable = lib.mkEnableOption "a remote Chrome DevTools endpoint";
    listenAddress = lib.mkOption {
      type = lib.types.str;
      description = "Guest address for the host-only DevTools forwarder.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9222;
      description = "DevTools port on the guest address.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
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

    systemd.services.remote-chrome-cleanup = {
      description = "Clear the remote Chrome profile";
      unitConfig.RequiresMountsFor = "/var/lib";
      serviceConfig.Type = "oneshot";
      path = [ pkgs.findutils ];
      script = ''
        systemctl stop remote-chrome-proxy.socket
        restart_browser() {
          systemctl start remote-chrome.service
          systemctl start remote-chrome-proxy.socket
        }
        trap restart_browser EXIT
        systemctl stop remote-chrome.service
        # DynamicUser stores StateDirectory contents below /var/lib/private.
        if [ -d /var/lib/private/remote-chrome ]; then
          find /var/lib/private/remote-chrome -mindepth 1 -delete
        fi
      '';
    };
    systemd.timers.remote-chrome-cleanup = {
      description = "Clear the remote Chrome profile at midnight";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
        Persistent = true;
      };
    };

    systemd.sockets.remote-chrome-proxy = {
      description = "Chrome DevTools guest socket";
      wantedBy = [ "sockets.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      socketConfig = {
        ListenStream = "${cfg.listenAddress}:${toString cfg.port}";
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
