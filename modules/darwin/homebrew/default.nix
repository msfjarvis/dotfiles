{ lib, ... }:
{
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_INSECURE_REDIRECT = "1";
    HOMEBREW_NO_EMOJI = "1";
  };
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = lib.mkDefault "uninstall";
      upgrade = true;
    };
  };
}
