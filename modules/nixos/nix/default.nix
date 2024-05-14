{
  lib,
  pkgs,
  config,
  inputs,
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
    package = pkgs.jarvis.nh;
    clean.enable = true;
    flake = "/home/msfjarvis/git-repos/dotfiles";
  };

  nix =
    lib.jarvis.mkNixConfig {
      inherit
        lib
        pkgs
        config
        inputs
        ;
    }
    // {
      optimise.automatic = true;
      settings.allowed-users = [ "@wheel" ];
      settings.trusted-users = [
        "root"
        "@wheel"
      ];
    };
}
