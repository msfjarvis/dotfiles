{
  lib,
  pkgs,
  namespace,
  ...
}:
{
  users.users.msfjarvis.packages = with pkgs; [
    expect
    nix-inspect
    nix-output-monitor
  ];

  programs.nh = {
    enable = true;
    clean.enable = false;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  nix =
    lib.${namespace}.mkNixConfig {
      inherit lib pkgs;
    }
    // {
      optimise.automatic = false;
    };

  system.switch = {
    enable = false;
    enableNg = true;
  };
}
