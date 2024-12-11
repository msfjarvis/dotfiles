{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.betula;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.${namespace}.betula = {
    enable = mkEnableOption { description = "Whether to enable the betula bookmarking service."; };

    domain = mkOption {
      type = types.nullOr types.str;
      example = "betula.example.com";
      description = "Domain name under which betula will be accessible. When set, will configure Caddy to serve betula under this domain.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/betula/";
      description = "Path to the directory where betula will persist its state.";
    };

    user = mkOption {
      type = types.str;
      default = "betula";
      description = "User account under which betula runs.";
    };

    group = mkOption {
      type = types.str;
      default = "betula";
      description = "Group account under which betula runs.";
    };

    package = mkPackageOption pkgs "betula" { };
  };

  config = mkIf cfg.enable {
    systemd.services.betula = {
      wantedBy = [ "default.target" ];
      after = [
        "fs.service"
        "networking.target"
      ];
      wants = [
        "fs.service"
        "networking.target"
      ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        Type = "simple";
      };
      script = ''
        ${lib.getExe cfg.package} ${cfg.dataDir}/sqlite.db
      '';
    };

    services.caddy.virtualHosts = mkIf (cfg.domain != null) {
      "https://${cfg.domain}" = {
        extraConfig = ''
          # Port hardcoded by betula
          reverse_proxy 127.0.0.1:1738
        '';
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} - -" ];

    users.users = mkIf (cfg.user == "betula") {
      betula = {
        inherit (cfg) group;
        createHome = false;
        description = "betula daemon user";
        isNormalUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "betula") { betula = { }; };
  };
}
