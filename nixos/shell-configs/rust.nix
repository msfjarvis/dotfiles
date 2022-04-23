with import <nixpkgs> { overlays = [ (import <rust-overlay>) ]; };
mkShell {
  buildInputs = [
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" "rustfmt-preview" "llvm-tools-preview" ];
        targets =
          pkgs.lib.optionals pkgs.stdenv.isDarwin [ "aarch64-apple-darwin" ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux
          [ "x86_64-unknown-linux-gnu" ];
      }))
  ];
}
