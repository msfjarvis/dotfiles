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
    nix-converter
    watchexec
  ];
  commands = [
    {
      name = "dev";
      category = "development";
      help = "Run a Glance server with an automatically updating config";
      command = ''
        out_conf=$(mktemp)
        ${getExe pkgs.watchexec} -r -w "${glanceConf}" -- "${getExe pkgs.nix-converter} --from-nix -f ${glanceConf} -l yaml > $out_conf" &
        ${getExe pkgs.glance} -config "$out_conf"
      '';
    }
  ];
}
