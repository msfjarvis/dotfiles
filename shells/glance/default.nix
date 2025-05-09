{ pkgs, lib, ... }:
let
  inherit (lib) getExe;
  glanceConf = "systems/aarch64-linux/wailord/glance.nix";
in
pkgs.devshell.mkShell {
  name = "glance-interactive";
  bash = {
    interactive = "";
  };
  packages = with pkgs; [
    glance
    watchexec
  ];
  commands = [
    {
      name = "dev";
      category = "development";
      help = "Run a Glance server with an automatically updating config";
      command = ''
        ${getExe pkgs.watchexec} -r -w "${glanceConf}" -- "./shells/glance/build.sh ${glanceConf}"
      '';
    }
  ];
}
