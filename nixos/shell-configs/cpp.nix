{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    busybox
    clang_12
    cmake
    lld_12
    openssl
    pkgconfig
    zlib
  ];
}
