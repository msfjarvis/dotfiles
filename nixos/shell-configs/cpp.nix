{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    busybox
    clang_13
    cmake
    lld_13
    openssl
    pkgconfig
    zlib
  ];
}
