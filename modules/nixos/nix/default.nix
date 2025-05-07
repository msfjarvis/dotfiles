{
  config,
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

  sops.secrets.nix-netrc-file = {
    sopsFile = lib.snowfall.fs.get-file "secrets/nix-cache.yaml";
    format = "yaml";
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

  system.switch = {
    enable = false;
    enableNg = true;
  };
}
