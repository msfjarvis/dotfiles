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
  palette =
    (lib.importJSON (config.catppuccin.sources.palette + "/palette.json"))
    .${config.catppuccin.flavor}.colors;
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
          font = "IosevkaTerm Nerd Font Mono 13";
          colors = with palette; {
            foregroundColor = text.hex; # base05
            backgroundColor = base.hex; # base00
            boldColor = surface2.hex; # base04
            palette = [
              base.hex # base00
              red.hex # base08
              green.hex # base0B
              yellow.hex # base0A
              blue.hex # base0D
              mauve.hex # base0E
              teal.hex # base0C
              text.hex # base05
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
