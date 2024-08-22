_: {
  projectRootFile = "flake.nix";

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
  programs.shfmt = {
    enable = true;
    indent_size = 2;
  };
  settings.formatter.shfmt.includes = [
    "scripts/*"
    "shell-init"
    "darwin-init"
  ];
  settings.formatter.shfmt.excludes = [
    "scripts/templates/*"
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
