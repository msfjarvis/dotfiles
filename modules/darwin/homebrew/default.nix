{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
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
