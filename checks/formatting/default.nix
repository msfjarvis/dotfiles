{ pkgs, lib, ... }:
pkgs.runCommandLocal "check-formatting"
  {
    nativeBuildInputs = with pkgs; [
      nixfmt-rfc-style
      deadnix
      shfmt
      statix
    ];
    src = lib.snowfall.fs.get-file "/";
  }
  ''
    shfmt --diff --simplify --language-dialect bash --indent 2 --case-indent --space-redirects .
    deadnix
    statix check .
    nixfmt --check .
    mkdir $out
  ''
