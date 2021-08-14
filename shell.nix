{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [ bash busybox nixfmt shellcheck shfmt ];
}
