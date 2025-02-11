{ pkgs, ... }:
(pkgs.buildFHSEnv {
  name = "arduino-env";
  targetPkgs =
    pkgs: with pkgs; [
      ncurses
      arduino-ide
      zlib
      (python3.withPackages (ps: [
        ps.pyserial
      ]))
    ];
  multiPkgs = null;
  runScript = "arduino-ide";
}).env
