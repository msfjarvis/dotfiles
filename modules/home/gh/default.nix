{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
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
