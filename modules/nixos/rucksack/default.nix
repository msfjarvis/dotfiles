{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.rucksack;
  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "rucksack.toml" {
    inherit (cfg) sources target file_filter;
  };
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.${namespace}.rucksack = {
    enable = mkEnableOption { description = "Whether to enable the rucksack daemon."; };

    sources = mkOption {
      # This can either be plain paths or struct types with modifiers
      type = types.listOf (types.either types.str types.attrs);
      default = [ ];
      description = "Directories to watch and pull files from";
    };

    target = mkOption {
      type = types.str;
      default = "";
      description = "Directory to move files from source directories";
    };

    file_filter = mkOption {
      type = types.str;
      default = "";
      description = "Shell glob to filter files against to be eligible for moving";
    };

    package = mkPackageOption pkgs.jarvis "rucksack" { };

    user = mkOption {
      type = types.str;
      default = "rucksack";
      description = "User account under which rucksack runs.";
    };

    group = mkOption {
      type = types.str;
      default = "rucksack";
      description = "Group account under which rucksack runs.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rucksack = {
      wantedBy = [ "default.target" ];
      after = [ "fs.service" ];
      wants = [ "fs.service" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "simple";
        Environment = [
          "RUCKSACK_CONFIG=${settingsFile}"
          "PATH=${pkgs.coreutils}/bin:${pkgs.watchman}/bin"
        ];
        ExecStart = "${lib.getExe cfg.package}";
      };
    };

    users.users = mkIf (cfg.user == "rucksack") {
      rucksack = {
        inherit (cfg) group;
        home = cfg.dataDir;
        createHome = false;
        description = "rucksack daemon user";
        isNormalUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "rucksack") {
      rucksack = {
        gid = null;
      };
    };
  };
}
