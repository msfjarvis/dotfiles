with import <nixpkgs> { overlays = [ (import <rust-overlay>) ]; };
mkShell {
  buildInputs = [
    (rust-bin.nightly."2022-02-14".default.override {
      extensions = [ "rust-src" "rustfmt-preview" ];
    })
  ];
}
