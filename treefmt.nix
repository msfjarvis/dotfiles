{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  package = pkgs.treefmt2;

  programs.actionlint = {
    enable = true;
  };
  programs.deadnix = {
    enable = true;
  };
  programs.jsonfmt = {
    enable = true;
  };
  programs.mdformat = {
    enable = true;
  };
  programs.nixfmt = {
    enable = true;
  };
  programs.shellcheck = {
    enable = true;
  };
  settings.formatter.shellcheck.includes = [
    "x"
    "scripts/*"
    "shell-init"
    "darwin-init"
  ];
  programs.shfmt = {
    enable = true;
    indent_size = 2;
  };
  settings.formatter.shfmt.includes = [
    "x"
    "scripts/*"
    "shell-init"
    "darwin-init"
  ];
  programs.statix = {
    enable = true;
  };
  programs.taplo = {
    enable = true;
  };
  programs.yamlfmt = {
    enable = true;
  };
}
