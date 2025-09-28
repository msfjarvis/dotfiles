{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkSystemSecret;
in
{
  users.users.msfjarvis.packages = with pkgs; [
    expect
    nix-inspect
    nix-output-monitor
  ];

  programs.nh = {
    enable = true;
    clean.enable = config.profiles.${namespace}.server.enable;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  sops.secrets.nix-netrc-file = mkSystemSecret {
    file = "nix-cache";
    key = "netrc-file";
  };

  nix =
    lib.${namespace}.mkNixConfig {
      inherit lib pkgs;
    }
    // {
      optimise.automatic = false;
      settings.netrc-file = config.sops.secrets.nix-netrc-file.path;
    };
}
