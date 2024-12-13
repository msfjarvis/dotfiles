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
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [
      "cocoapods"
      "carthage"
      "gnu-sed"
      "ruby"
    ];
    casks = [
      "flutter"
      "zed"
    ];
    taps = [ ];
  };
}
