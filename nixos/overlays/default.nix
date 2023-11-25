_: prev: {
  # Prevent using NixOS JDK, we'll use ours.
  maestro = prev.maestro.overrideAttrs (_: {
    postFixup = "";
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [./megatools.patch];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override {
    fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
  };
  # Drop patch that enforces software rendering
  scrcpy = prev.scrcpy.overrideAttrs (_: {postPatch = "";});
}
