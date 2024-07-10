{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.profiles.zed;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.zed = {
    enable = mkEnableOption "Enable zed editor (zed.dev)";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Nix
      nixd
      # Rust
      inputs.fenix.packages.${system}.rust-analyzer
      zed-editor
    ];
  };
}
