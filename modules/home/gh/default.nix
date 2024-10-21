{ config, pkgs, namespace, ... }:
{
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = config.profiles.${namespace}.starship.server;
    settings = {
      version = 1;
      git_protocol = "https";
      editor = "micro";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        vw = "pr view --web";
      };
    };
    extensions = [ pkgs.gh-poi ];
  };
}
