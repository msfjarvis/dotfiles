{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.profiles.${namespace}.pass.git-helper;

  mappingFormat = pkgs.formats.ini { };

  mappingModule = types.submodule {
    freeformType = mappingFormat.type;
  };

  mappingFile = mappingFormat.generate "git-pass-mapping.ini" cfg.mapping;

in
{
  options.profiles.${namespace}.pass.git-helper = {
    enable = mkEnableOption "password-store credential helper";

    package = mkOption {
      type = types.package;
      default = pkgs.gitAndTools.pass-git-helper;
      defaultText = literalExpression "pkgs.gitAndTools.pass-git-helper";
      description = ''
        pass-git-helper package to install.
      '';
    };

    mapping = mkOption {
      type = mappingModule;
      default = { };
      example = literalExpression ''
        {
          "github.com*".target = "dev/github";
          "gitlab.*" = {
            target = "dev/gitlab/user@example.com";
            username_extractor = "entry_name";
            skip_password = 10;
          };
        }
      '';
      description = ''
        Mapping of host pattern to a target entry in the
        password store.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.git.extraConfig.credential.helper = "${cfg.package}/bin/pass-git-helper -m ${mappingFile}";
  };
}
