{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.pi;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.profiles.${namespace}.pi = {
    enable = mkEnableOption "pi, an extensible coding harness";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_latest
      pkgs.llm-agents.rtk
      pkgs.llm-agents.skills
      pkgs.${namespace}.markfmt
    ];

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs.llm-agents.pi;
    };
  };
}
