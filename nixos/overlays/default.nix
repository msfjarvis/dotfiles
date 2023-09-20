final: prev: {
  maestro = prev.maestro.overrideAttrs (old: {
    postFixup = "";
  });
  megatools = prev.megatools.overrideAttrs (old: {
    patches = [./megatools.patch];
  });
  nerdfonts = prev.nerdfonts.override {
    fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
  };
  scrcpy = prev.scrcpy.overrideAttrs (old: {postPatch = "";});
}
