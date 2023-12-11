_: prev: {
  # Downgrade gh to 2.39.2 while multi-account support
  # is made compatible with home-manager
  gh = prev.gh.overrideAttrs (_: rec {
    version = "2.39.2";
    src = prev.fetchFromGitHub {
      owner = "cli";
      repo = "cli";
      rev = "v${version}";
      hash = "sha256-6FjsUEroHpAjQj+7Z/C935LunYbgAzRvQI2pORiLo3s=";
    };
  });
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
