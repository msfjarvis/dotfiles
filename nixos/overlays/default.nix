final: prev: {
  # Prevent using NixOS JDK, we'll use ours.
  maestro = prev.maestro.overrideAttrs (old: {
    postFixup = "";
  });
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (old: {
    patches = [./megatools.patch];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override {
    fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
  };
  # Drop patch that enforces software rendering
  scrcpy = prev.scrcpy.overrideAttrs (old: {postPatch = "";});
}
