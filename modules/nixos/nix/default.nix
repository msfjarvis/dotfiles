{
  lib,
  pkgs,
  namespace,
  ...
}:
{
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
  };

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
