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
    jarvis.nix-inspect
    nix-output-monitor
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  nix = lib.${namespace}.mkNixConfig { inherit lib pkgs; } // {
    optimise.automatic = true;
    settings.allowed-users = [ "@wheel" ];
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
