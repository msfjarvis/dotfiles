_: prev: {
  # Force the use of the JDK we're using everywhere else
  maestro = prev.maestro.override {
    jre_headless = prev.temurin-bin-21;
  };
  # Silence warnings about existing files
  megatools = prev.megatools.overrideAttrs (_: {
    patches = [./megatools.patch];
  });
  # Set default fonts
  nerdfonts = prev.nerdfonts.override {
    fonts = ["JetBrainsMono"];
  };
  scrcpy = prev.scrcpy.overrideAttrs (_: {
    # Fixes bash completion, drop after next release.
    patches = [./scrcpy-bash-comp.patch ./scrcpy-bash-compgen.patch];
  });
}
