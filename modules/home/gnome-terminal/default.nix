{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.gnome-terminal;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.gnome-terminal = {
    enable = mkEnableOption "GNOME Terminal";
  };
  config = mkIf cfg.enable {
    programs.gnome-terminal = {
      enable = true;
      profile = {
        "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
          default = true;
          visibleName = "Catppuccin Mocha";
          colors = with config.lib.stylix.colors.withHashtag; {
            foregroundColor = base05;
            backgroundColor = base00;
            boldColor = base04;
            palette = [
              base00
              base08
              base0B
              base0A
              base0D
              base0E
              base0C
              base05
            ];
          };
          boldIsBright = false;
          audibleBell = false;
        };
      };
    };
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
        binding = "<Control><Alt>t";
        command = "${lib.getExe pkgs.gnome-terminal}";
      };
    };
  };
}
