with import <nixpkgs> { overlays = [ (import <rust-overlay>) ]; };
mkShell {
  buildInputs = [
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" "rustfmt-preview" ];
      }))
  ];
}
