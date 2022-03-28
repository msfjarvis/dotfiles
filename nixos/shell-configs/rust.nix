with import <nixpkgs> { overlays = [ (import <rust-overlay>) ]; };
mkShell {
  buildInputs = [
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rustfmt-preview" ];
      targets =
        pkgs.lib.optionals pkgs.stdenv.isDarwin [ "aarch64-apple-darwin" ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux
        [ "x86_64-unknown-linux-musl" ];
    })
  ];
}
