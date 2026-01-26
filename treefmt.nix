{ pkgs, ... }:
let
  shellScripts = [
    "x"
    "scripts/*"
    "shell-init"
    "darwin-init"
  ];
in
{
  projectRootFile = "flake.nix";
  package = pkgs.treefmt;

  programs.actionlint = {
    enable = true;
  };
  programs.black = {
    enable = true;
  };
  programs.deadnix = {
    enable = true;
  };
  programs.jsonfmt = {
    enable = true;
  };
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
  };
  programs.shellcheck = {
    enable = true;
  };
  settings.formatter.shellcheck.includes = shellScripts;
  programs.shfmt = {
    enable = true;
    indent_size = 2;
  };
  settings.formatter.shfmt.includes = shellScripts;
  programs.statix = {
    enable = true;
  };
  programs.taplo = {
    enable = true;
  };
  programs.yamlfmt = {
    enable = true;
  };

  settings.formatter.markdown-code-runner = {
    command = pkgs.lib.getExe pkgs.markdown-code-runner;
    options =
      let
        config = pkgs.writers.writeTOML "markdown-code-runner-config" {
          presets.nixfmt = {
            language = "nix";
            command = [ (pkgs.lib.getExe pkgs.nixfmt) ];
          };
        };
      in
      [ "--config=${config}" ];
    includes = [ "*.md" ];
  };
}
