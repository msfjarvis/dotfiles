{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
  cfg = config.profiles.${namespace}.zed;
  jsonFormat = pkgs.formats.json { };

  mergedSettings = cfg.userSettings // {
    # this part by @cmacrae
    auto_install_extensions = lib.listToAttrs (map (ext: lib.nameValuePair ext true) cfg.extensions);
  };
in
{
  options.profiles.${namespace}.zed = {
    enable = mkEnableOption "Zed, the high performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    package = mkPackageOption pkgs "zed-editor" { };

    userSettings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Configuration written to Zed's {file}`settings.json`.
      '';
    };

    userKeymaps = mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Configuration written to Zed's {file}`keymap.json`.
      '';
    };

    extensions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        A list of the extensions Zed should install on startup.
        Use the name of a repository in the [extension list](https://github.com/zed-industries/extensions/tree/main/extensions).
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        A list of additional packages to install alongside Zed.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ cfg.extraPackages;
    xdg.configFile."zed/settings.json" = mkIf (mergedSettings != { }) {
      source = jsonFormat.generate "zed-user-settings" mergedSettings;
    };
    xdg.configFile."zed/keymap.json" = mkIf (cfg.userKeymaps != { }) {
      source = jsonFormat.generate "zed-user-keymaps" cfg.userKeymaps;
    };
  };
}
