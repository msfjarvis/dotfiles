{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qbittorrent;
  configDir = "${cfg.dataDir}/.config";
  openFilesLimit = 4096;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  prometheusType = types.submodule {
    options = {
      enable = mkEnableOption "Attach a Prometheus exporter to the QBittorrent server.";
      port = mkOption {
        type = types.port;
        default = 9999;
        description = "Port on which the Prometheus exporter runs.";
      };
    };
  };
in
{
  options.services.qbittorrent = {
    enable = mkEnableOption "Run qBittorrent headlessly as systemwide daemon";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    openFilesLimit = mkOption {
      default = openFilesLimit;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };

    prometheus = mkOption {
      type = prometheusType;
      default = { };
      description = "Prometheus settings.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.qbittorrent ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.qbittorrent ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.qbittorrent}/bin/qbittorrent-nox \
            --profile=${configDir} \
            --webui-port=${toString cfg.port}
        '';
        # To prevent "Quit & shutdown daemon" from working; we want systemd to
        # manage it!
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        LimitNOFILE = cfg.openFilesLimit;
      };
    };

    systemd.services.prometheus-qbittorrent-exporter = mkIf cfg.prometheus.enable {
      after = [ "qbittorrent.service" ];
      description = "qBittorrent Prometheus exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          exec env QBITTORRENT_HOST=localhost QBITTORRENT_PORT=${toString cfg.port} EXPORTER_PORT=${toString cfg.prometheus.port} ${lib.getExe pkgs.jarvis.prometheus-qbittorrent-exporter}
        '';
        User = cfg.user;
        Group = cfg.group;
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        inherit (cfg) group;
        home = cfg.dataDir;
        createHome = true;
        description = "qBittorrent Daemon user";
        isNormalUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {
        gid = null;
      };
    };
  };
}
