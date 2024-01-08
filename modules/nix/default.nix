{
  lib,
  inputs,
  ...
}: let
  inherit (lib) filterAttrs;
  flakes = filterAttrs (_name: value: value ? outputs) inputs;

  nixRegistry =
    builtins.mapAttrs
    (_name: v: {flake = v;})
    flakes;
in {
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
    };
    registry = nixRegistry;
    settings = {
      trusted-substituters = [
        "https://msfjarvis.cachix.org"
      ];
      trusted-public-keys = [
        "msfjarvis.cachix.org-1:/sKPgZblk/LgoOKtDgMTwvRuethILGkr/maOvZ6W11U="
      ];
      trusted-users = ["msfjarvis" "root"];
    };
  };
}
