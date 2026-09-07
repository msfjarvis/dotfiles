{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.services.${namespace}.bookorbit;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
  publicUrl = "https://${cfg.domain}";
in
{
  options.services.${namespace}.bookorbit = {
    enable = mkEnableOption "BookOrbit";

    domain = mkOption {
      type = types.str;
      description = "Fully-qualified public hostname for BookOrbit's HTTPS Caddy virtual host.";
      example = "books.example.com";
    };

    clientUrl = mkOption {
      type = types.str;
      default = publicUrl;
      description = "Browser client URL when it differs from BookOrbit's public URL.";
    };

    port = mkOption {
      type = types.port;
      default = ports.bookorbit;
      description = "TCP port on which BookOrbit listens.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/bookorbit";
      description = "Persistent BookOrbit application data directory.";
    };

    booksDir = mkOption {
      type = types.str;
      default = "/var/lib/bookorbit/books";
      description = "Host directory mounted in the service at /books.";
    };

    environmentFile = mkOption {
      type = types.path;
      example = "/run/secrets/bookorbit.env";
      description = ''
        Environment file containing JWT_SECRET and SETUP_BOOTSTRAP_TOKEN. It
        may also contain supported optional BookOrbit environment variables.
      '';
    };

    userId = mkOption {
      type = types.int;
      example = 987;
      description = "Stable host UID for the BookOrbit system account.";
    };

    groupId = mkOption {
      type = types.int;
      example = 984;
      description = "Stable host GID for the BookOrbit system account.";
    };

    libraryBrowseRoot = mkOption {
      type = types.str;
      default = "/books";
      description = "Directory at which BookOrbit's library picker starts.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open BookOrbit's HTTP port in the firewall.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 bookorbit bookorbit - -"
      "d ${cfg.booksDir} 0750 bookorbit bookorbit - -"
    ];

    # Override the upstream module's generated account IDs to retain ownership
    # of data created by the previous OCI deployment.
    users.groups.bookorbit.gid = cfg.groupId;
    users.users.bookorbit.uid = cfg.userId;

    services.bookorbit = {
      enable = true;
      inherit (cfg) environmentFile openFirewall;
      environment = {
        APP_DATA_PATH = cfg.dataDir;
        PORT = cfg.port;
        APP_URL = publicUrl;
        CLIENT_URL = cfg.clientUrl;
        LIBRARY_BROWSE_ROOT = cfg.libraryBrowseRoot;
        # APP_DATA_PATH changes from the OCI-visible /data to its host path.
        # Retain the old Book Dock path so pending-import rows still match.
        BOOK_DOCK_PATH = "/data/book-dock";
      };
    };

    # Existing database rows contain absolute /books paths. Keep that path
    # available to the upstream native service while retaining host storage.
    # Pending Book Dock imports similarly retain absolute /data paths.
    systemd.services.bookorbit = {
      path = [
        pkgs.ffmpeg
        pkgs.poppler-utils
      ];
      serviceConfig.BindPaths = [
        "${cfg.dataDir}:/data"
        "${cfg.booksDir}:/books"
      ];
    };

    services.caddy.virtualHosts."https://${cfg.domain}" = {
      logFormat = lib.${namespace}.mkReactionLogFormat cfg.domain;
      extraConfig = ''
        encode gzip zstd
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
