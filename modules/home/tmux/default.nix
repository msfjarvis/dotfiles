{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set-environment -g COLORTERM "truecolor"
    '';
  };
  home.packages = [ pkgs.byobu ];
}
