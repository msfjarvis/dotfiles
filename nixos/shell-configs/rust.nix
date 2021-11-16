with import <nixpkgs> { overlays = [ (import <rust-overlay>) ]; };
mkShell {
  buildInputs = [
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-analyzer-preview" "rust-src" "rustfmt-preview" ];
      }))
  ];
}
