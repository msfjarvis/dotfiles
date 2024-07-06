{ lib, system, ... }:
lib.mkIf (lib.strings.hasSuffix "darwin" system) {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
