{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.opencode;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.profiles.${namespace}.opencode = {
    enable = mkEnableOption "opencode, an AI coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mcporter
    ];

    programs.opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;

      settings = {
        model = "github-copilot/claude-sonnet-4.6";
        disabled_providers = [ "opencode" ];
        enabled_providers = [ "github-copilot" ];
        provider = { };
        mcp = { };
        plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
        permission = {
          bash = "ask";
          edit = "ask";
          webfetch = "ask";
          read = {
            "*" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
            "*.dev.vars" = "deny";
            "~/.local/share/opencode/mcp-auth.json" = "deny";
            "$HOME/.local/share/opencode/mcp-auth.json" = "deny";
          };
          external_directory = {
            "*" = "ask";
            "~/.local/share/opencode/*" = "deny";
          };
        };
      };

      agents = {
        research = ./agents/research.md;
        review = ./agents/review.md;
      };

      commands = {
        read-branch-code = ./commands/read-branch-code.md;
        review-branch-code = ./commands/review-branch-code.md;
        search = ./commands/search.md;
      };
    };
  };
}
