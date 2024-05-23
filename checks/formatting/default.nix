{ pkgs, lib, ... }:
pkgs.stdenvNoCC.mkDerivation {
  name = "check-fmt";
  src = lib.snowfall.fs.get-file "/";
  dontBuild = true;
  doCheck = true;
  nativeBuildInputs = with pkgs; [
    nixfmt-rfc-style
    deadnix
    shfmt
    statix
  ];
  checkPhase = ''
    shfmt --diff --simplify --language-dialect bash --indent 2 --case-indent --space-redirects .
    deadnix
    statix check .
    nixfmt --check .
  '';
  installPhase = ''mkdir "$out"'';
}
