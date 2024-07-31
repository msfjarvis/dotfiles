{
  lib,
  pkgs,
  inputs,
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
    clean.enable = true;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  nix = lib.${namespace}.mkNixConfig { inherit lib pkgs inputs; } // {
    optimise.automatic = true;
    settings.allowed-users = [ "@wheel" ];
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
